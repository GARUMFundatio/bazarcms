module Bazarcms
  
  class EmpresasController < ApplicationController
  require "net/http"
  require "uri"
  
  unloadable
  
  layout "bazar"
  def index
    @empresas = Empresa.all.paginate(:page => params[:page], :per_page => 15)
    puts @empresas.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @empresas }
    end
  end

  def show
    @empresa = Empresa.find(params[:id])

    respond_to do |format|
      format.html { render :action => "show" }
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
    puts "paso por el edit"
    puts params.inspect

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
    puts "datos de las empresas"
    puts @empresa.inspect
    puts @empresasdatos.inspect

  end

  def create
    puts "pasa por el create "
    puts params.inspect
    @empresa = Empresa.new(params[:bazarcms_empresa])
    @empresa.user_id = current_user.id
    @empresa.id = current_user.id
    @empresasdatos = Bazarcms::Empresasdato.where('empresa_id = '+params[:id]+' and periodo >= '+@empresa.fundada.to_s)
    
    respond_to do |format|
      if @empresa.save
        puts "se ha creado la empresa:"+@empresa.id.to_s+' '+@empresa.user_id.to_s
        format.html { redirect_to(@empresa, :notice => 'Se ha creado correctamente la empresa.') }
        format.xml  { render :xml => @empresa, :status => :created, :location => @empresa }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @empresa.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    puts params.inspect
    @empresa = Empresa.find(params[:id])
    @empresasdatos = Bazarcms::Empresasdato.where('empresa_id = '+params[:id]+' and periodo >= '+@empresa.fundada.to_s)
    
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
    @consulta.desc = params[:q]
    @consulta.total_consultas = @clusters.count()
    @consulta.total_respuestas = 0
    @consulta.total_resultados = 0
    @consulta.fecha_inicio = DateTime::now
    @consulta.fecha_fin = DateTime::now
    @consulta.sql = params[:q]
    @consulta.save
    
    conta = 0
    micluster = BZ_param("BazarId").to_i;
    puts "ID de mi cluster #{micluster} <------"

    for cluster in @clusters
      puts "Enviando Petición a #{cluster.url}/bazarcms/buscaempresas?q=#{params[:q]}&bid=#{@consulta.id}&cid=#{micluster}"
     
      if micluster != cluster.id 
        
        uri = URI.parse("#{cluster.url}/bazarcms/buscaempresas?q=#{params[:q]}&bid=#{@consulta.id}&cid=#{micluster}")

        post_body = []
        post_body << "Content-Type: text/plain\r\n"

        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        request.body = post_body.join
        request["Content-Type"] = "text/plain"
      
        res = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) }
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          conta += 1
          # puts "fue bien (#{res.body})"
          
          empresas = JSON.parse(res.body)

          puts "#{empresas.inspect} <-----------"
          empresas.each{ |key|
            puts ("#{key.inspect}")
            puts ("#{key['empresa'].inspect} <------ datos")
            resu = Bazarcms::Empresasresultado.new()
            resu.empresasconsulta_id = @consulta.id
            resu.cluster_id = cluster.id
            resu.empresa_id = key['empresa']['id'] 
            resu.enlace = "poner el enlace remoto bien"
            resu.orden = key['empresa']['nombre']
            resu.info = key['empresa']['nombre']
            resu.save
            }
            
          @consulta.total_respuestas = @consulta.total_respuestas + 1;
          @consulta.save
        else
          puts res.error!
        end
      else 
        
        # TODO optimizar para que primero busque en local y saque los primeros 
        # resultados y luego mande las peticiones remotas. 
        
        puts "busco en local"
        conta += 1 
        
        @consulta.total_respuestas = @consulta.total_respuestas + 1;
        @consulta.save

        resultados = Empresa.find_with_ferret(params[:q])
        puts "resu: (#{resultados.inspect}) <-------"
        
        conta2 = 0
        for resu in resultados 
          @res = Empresasresultado.new(); 
          @res.empresasconsulta_id = @consulta.id
          @res.cluster_id = micluster
          @res.empresa_id = resu.id 
          @res.orden = resu.nombre
          @res.enlace = "poner la url bien"
          @res.info = "#{resu.nombre}"
          @res.save
          conta2 += 1 
        end 
        @consulta.total_resultados = @consulta.total_resultados + conta2;
        @consulta.save
      end 
      
    end 
    
    @consulta.total_consultas = conta;
    @consulta.save

    respond_to do |format|
      format.html { redirect_to '/bazarcms/empresasconsultas/'+@consulta.id.to_s+'?display=inside'}
    end
    
  end
   
  # handle_asynchronously :enviabusqueda
  
  def buscador
    
  end 

  def busca 

    puts "he recibido una peticion de busqueda #{params[:q]} "
  
    resultados = Empresa.find_with_ferret(params[:q])

# TODO en la siguiente versión debería ser algo así
# de momento va bién así, pero se puede optimizar ...
    
#   if (resultados.count)
#     puts "envío el resultado de la busqueda"
      
#     cluster = Cluster.find_by_id(params[:cid])
#     puts ("#{cluster.url}/bazarcms/resultadoempresas?bid=#{params[:bid]}")
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
#        puts "fue bien (#{res.body})"
#      else
#        puts res.error!
#      end
#   end
   
  render :json => resultados

  end 
  
  # TODO desactivada la respuesta asincrona que solo hay una máquina externa 
  # para hacer pruebas y está detrás de un NAT
  
  def resultado 
    puts "recibiendo resultado de la busqueda (#{params[:bid]})"
    render :layout => false
  end 
  
end

end

