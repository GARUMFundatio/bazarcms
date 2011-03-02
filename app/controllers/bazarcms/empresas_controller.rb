module Bazarcms
  
  class EmpresasController < ApplicationController
  require "net/http"
  require "uri"
  
  unloadable
  before_filter :require_no_user, :only => [:show2, :busca]
  before_filter :require_user, :only => [:show, :index, :edit, :create, :update, :dashboard, :enviabusqueda, :buscador, :estadobusqueda, :resultado, :sitios]
  
  layout "bazar"
  def index
    @empresas = Empresa.all.paginate(:page => params[:page], :per_page => 15)
    logger.debug @empresas.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @empresas }
    end
  end

  def list
    @empresas = Empresa.where('1 = 1').order("nombre asc")
    logger.debug @empresas.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @empresas }
    end
  end

  # muestra la información de una empresa para usuarios registrados en bazar 

  def show
    
    @empresa = Empresa.find(params[:id])
    @empresasdatos = Empresasdato.where("empresa_id = ? and periodo >= ?", params[:id], @empresa.fundada).order("periodo")
    @usuario = User.find(params[:id])
    respond_to do |format|
      format.html { render :action => "show" }
      format.xml  { render :xml => @empresa }
    end

  end

  # muestra la información de una empresa para usuarios no registrados en bazar 
  
  def show2
    @empresa = Empresa.find(params[:id])

    respond_to do |format|
      format.html { render :action => "show2", :layout => false }
      format.xml  { render :xml => @empresa }
    end

  end

  def new
    @empresa = Empresa.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @empresa }
    end
  end

  def edit
    logger.debug "paso por el edit"
    logger.debug params.inspect

    @empresa = Empresa.find_by_id(params[:id])
    if (@empresa.nil?) then
      @empresa = Empresa.new
      @empresa.id = params[:id]
      @empresa.user_id = params[:id]
      @empresa.nombre  = 'Escriba su nombre Aquí'
      @empresa.desc    = 'Describa su empresa'
      @empresa.fundada = 2005 
      @empresa.moneda = 0
      @empresa.save
      
    end
    
    $i = @empresa.fundada;
    $num = DateTime.now.year;

# relleno los datos financieros si no existen
    while $i <= $num  do
      @eb = Bazarcms::Empresasdato.find_by_empresa_id_and_periodo(params[:id], $i)
      
      if (@eb.nil?) then
        @eb = Bazarcms::Empresasdato.new
        @eb.empresa_id = params[:id];
        @eb.periodo = $i
        @eb.empleados = 0
        @eb.ventas = 0
        @eb.compras = 0
        @eb.resultados = 0
        @eb.save
      end
      $i +=1;
    end
     
    # TODO JT gestionar cuando solo hay un dato o ninguno (no debería)
    
    @empresasdatos = Bazarcms::Empresasdato.where('empresa_id = '+params[:id]+' and periodo >= '+@empresa.fundada.to_s)
    logger.debug "datos de las empresas"
    logger.debug @empresa.inspect
    logger.debug @empresasdatos.inspect

  end

  def create
    logger.debug "pasa por el create "
    logger.debug params.inspect
    @empresa = Empresa.new(params[:bazarcms_empresa])
    @empresa.user_id = current_user.id
    @empresa.id = current_user.id
    @empresasdatos = Bazarcms::Empresasdato.where('empresa_id = '+params[:id]+' and periodo >= '+@empresa.fundada.to_s)
  
    Actividad.graba("Ha creado una nueva empresa.", "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)
    
    respond_to do |format|
      if @empresa.save
        logger.debug "se ha creado la empresa:"+@empresa.id.to_s+' '+@empresa.user_id.to_s
        format.html { redirect_to(@empresa, :notice => 'Se ha creado correctamente la empresa.') }
        format.xml  { render :xml => @empresa, :status => :created, :location => @empresa }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @empresa.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    logger.debug params.inspect
    @empresa = Empresa.find(params[:id])
    @empresasdatos = Bazarcms::Empresasdato.where('empresa_id = '+params[:id]+' and periodo >= '+@empresa.fundada.to_s)
      
    Actividad.graba("Actualizada información empresa.", "USER",  BZ_param("BazarId"), current_user.id, @empresa.nombre)
    
    respond_to do |format|
      if @empresa.update_attributes(params[:bazarcms_empresa])
        # format.html { redirect_to(@empresa, :notice => 'Se ha actualizado correctamente la empresa.') }
        format.html { render :action => "edit" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @empresa.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @empresa = Empresa.find(params[:id])
    @empresa.destroy

    respond_to do |format|
      format.html { redirect_to(empresas_url) }
      format.xml  { head :ok }
    end
  end
  
  def dashboard 
    @ultimas = Empresa.ultimascreadas
    @actualizadas = Empresa.ultimasactualizadas
    @total = Empresa.count
    respond_to do |format|
      format.html { render :layout => false }
    end
  end 
  
  def enviabusqueda()
    @clusters = Cluster.where("activo = 'S'")
    
    @consulta = Empresasconsulta.new
    @consulta.empresa_id = current_user.id 
    
    logger.debug "------> (#{params[:q]}) unscaped (#{CGI.unescape(params[:q])})"
    logger.debug "------> (#{params.inspect})"
    
    @consulta.desc = CGI.unescape(params[:q])
    @consulta.total_consultas = @clusters.count()
    @consulta.total_respuestas = 0
    @consulta.total_resultados = 0
    @consulta.fecha_inicio = DateTime::now
    @consulta.fecha_fin = nil
    @consulta.sql = params[:q]
    @consulta.save
    
    conta = 0
    micluster = BZ_param("BazarId").to_i;
    logger.debug "ID de mi cluster #{micluster} <------"
    
    # primero buscamos en local para ofrecer los primeros resultados antes
    
      logger.debug "busco en local"
      conta += 1 
      
      @consulta.total_respuestas = @consulta.total_respuestas + 1;
      @consulta.save

      resultados = Empresa.find_with_ferret(params[:q])
      logger.debug "resu: (#{resultados.inspect}) <-------"
      
      conta2 = 0
      for resu in resultados 
        
        entra = 0
        total = 0
        datos = Bazarcms::Empresasdato.where("empresa_id = ?", [resu.id]).order('periodo desc').limit(1)

        logger.debug "datos seleccionados para el filtro #{datos.inspect}"
        # aplicamos el filtro de empleados 

        rangoe = params[:qe].split(' ')
        # puede que existan empresas que todavía no tienen datos!!!!
        if (!datos.nil?)
          if datos[0].empleados >= rangoe[0].to_i && datos[0].empleados <= rangoe[1].to_i
            entra += 1 
          end
        end
        total+=1

        rangoc = params[:qc].split(' ')
        if (!datos.nil?)
          if datos[0].compras >= rangoc[0].to_i && datos[0].compras <= rangoc[1].to_i
            entra += 1 
          end
        end
        total+=1

        rangov = params[:qv].split(' ')
        if (!datos.nil?)
          if datos[0].ventas >= rangov[0].to_i && datos[0].ventas <= rangov[1].to_i
            entra += 1 
          end
        end
        total+=1

        rangor = params[:qr].split(' ')
        if (!datos.nil?)
          if datos[0].resultados >= rangor[0].to_i && datos[0].resultados <= rangor[1].to_i
            entra += 1 
          end
        end
        total+=1

        if (entra == total)
          @res = Empresasresultado.new(); 
          @res.empresasconsulta_id = @consulta.id
          @res.cluster_id = micluster
          @res.empresa_id = resu.id 
          @res.orden = resu.nombre
          @res.enlace = resu.url
          @res.info = "#{resu.nombre}"
          @res.save
          conta2 += 1
        end 
         
      end 
      @consulta.total_resultados = @consulta.total_resultados + conta2;
      @consulta.save 
    
    # luego lanzamos las busquedas al resto de los bazares

    for cluster in @clusters
      logger.debug "Enviando Petición a #{cluster.url}/bazarcms/buscaempresas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&bid=#{@consulta.id}&cid=#{micluster}"
     
      if micluster != cluster.id 
        
        uri = URI.parse("#{cluster.url}/bazarcms/buscaempresas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&bid=#{@consulta.id}&cid=#{micluster}")

        post_body = []
        post_body << "Content-Type: text/plain\r\n"
        
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = http.read_timeout = 20
        
        request = Net::HTTP::Get.new(uri.request_uri)
        request.body = post_body.join
        request["Content-Type"] = "text/plain"
      
        begin 
          
          res =  Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) }
          case res
          when Net::HTTPSuccess, Net::HTTPRedirection
            conta += 1
            conta2 = 0
            empresas = JSON.parse(res.body)

            logger.debug "#{empresas.inspect} <-----------"
            empresas.each{ |key|
              logger.debug("#{key.inspect}")
              logger.debug("#{key['empresa'].inspect} <------ datos")
              resu = Bazarcms::Empresasresultado.new()
              resu.empresasconsulta_id = @consulta.id
              resu.cluster_id = cluster.id
              resu.empresa_id = key['empresa']['id'] 
              resu.enlace = key['empresa']['url']
              resu.orden = key['empresa']['nombre']
              resu.info = key['empresa']['nombre']
              resu.save
              conta2 += 1
              }
            
            @consulta.total_respuestas = @consulta.total_respuestas + 1;
            @consulta.total_resultados = @consulta.total_resultados + conta2;
            @consulta.save
          else
            logger.debug "ERROR en la petición a #{uri}---------->"+res.error!
          end
        
        rescue Exception => e
          logger.debug "Exception leyendo #{cluster.url} Got #{e.class}: #{e}"        
        end
        
      end
               

    end 
    
    @consulta.total_consultas = conta;
    @consulta.fecha_fin = DateTime::now

    @consulta.save

    respond_to do |format|
      format.html { redirect_to '/bazarcms/empresasconsultas/'+@consulta.id.to_s+'?display=inside'}
    end
    
  end
  
  def buscador
    
  end 

  def busca 

    logger.debug "he recibido una peticion de busqueda #{params[:q]} "
    params[:q] = CGI.unescape(params[:q])
    params[:qe] = CGI.unescape(params[:qe])
    params[:qv] = CGI.unescape(params[:qv])
    params[:qc] = CGI.unescape(params[:qc])
    params[:qr] = CGI.unescape(params[:qr])
    
    logger.debug "decodeado #{params[:q]}"
    logger.debug "decodeado #{params[:qe]}"
    logger.debug "decodeado #{params[:qv]}"
    logger.debug "decodeado #{params[:qc]}"
    logger.debug "decodeado #{params[:qr]}"
    
    resultados = Empresa.find_with_ferret(params[:q])
    
    logger.debug "#{resultados.inspect}"
    resultados2 = []
    for empre in resultados
      entra = 0
      total = 0
      datos = Bazarcms::Empresasdato.where("empresa_id = ?", [empre[:id]]).order('periodo desc').limit(1)
      
      logger.debug "datos seleccionados para el filtro #{datos.inspect}"
      # aplicamos el filtro de empleados 
      
      rangoe = params[:qe].split(' ')
      # puede que existan empresas que todavía no tienen datos!!!!
      if (!datos.nil?)
        if datos[0].empleados >= rangoe[0].to_i && datos[0].empleados <= rangoe[1].to_i
          entra += 1 
        end
      end
      total+=1
      
      rangoc = params[:qc].split(' ')
      if (!datos.nil?)
        if datos[0].compras >= rangoc[0].to_i && datos[0].compras <= rangoc[1].to_i
          entra += 1 
        end
      end
      total+=1
      
      rangov = params[:qv].split(' ')
      if (!datos.nil?)
        if datos[0].ventas >= rangov[0].to_i && datos[0].ventas <= rangov[1].to_i
          entra += 1 
        end
      end
      total+=1
      
      rangor = params[:qr].split(' ')
      if (!datos.nil?)
        if datos[0].resultados >= rangor[0].to_i && datos[0].resultados <= rangor[1].to_i
          entra += 1 
        end
      end
      total+=1
      
      if (entra == total)
        resultados2 << empre
      end 
      
    end 
    
    logger.debug "filtrados #{resultados2.inspect}"
    
# TODO en la siguiente versión debería ser algo así
# de momento va bién así, pero se puede optimizar ...
    
#   if (resultados.count)
#     logger.debug "envío el resultado de la busqueda"
      
#     cluster = Cluster.find_by_id(params[:cid])
#     logger.debug ("#{cluster.url}/bazarcms/resultadoempresas?bid=#{params[:bid]}")
#     uri = URI.parse("#{cluster.url}/bazarcms/resultadoempresas?bid=#{params[:bid]}")

#    post_body = []
#    post_body << "Content-Type: text/plain\r\n"
      # post_body << resultados.to_json
    
#    http = Net::HTTP.new(uri.host, uri.port)
#    request = Net::HTTP::Post.new(uri.request_uri)
#    request.body = post_body.join
#    request["Content-Type"] = "text/plain"
  
#    res = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) }
#    case res
#      when Net::HTTPSuccess, Net::HTTPRedirection
#        logger.debug "fue bien (#{res.body})"
#      else
#        logger.debug res.error!
#      end
#   end
   
  render :json => resultados2

  end 
  
  # TODO desactivada la respuesta asincrona que solo hay una máquina externa 
  # para hacer pruebas y está detrás de un NAT
  def estadobusqueda 
    estado = Bazarcms::Empresasconsulta.where("empresa_id = ?", current_user[:id]).order('fecha_inicio desc').limit(1)
    logger.debug "Estado de la consulta para el usuario #{current_user[:id]}: #{estado.inspect}"
    render :json => estado
  end 
  
  def resultado 
    logger.debug "recibiendo resultado de la busqueda ("+CGI.unescape(params[:bid])+")"
    render :layout => false
  end 

  
end

end

