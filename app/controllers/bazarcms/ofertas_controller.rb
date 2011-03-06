module Bazarcms
  
  class OfertasController < ApplicationController
  require "net/http"
  require "uri"
  
  unloadable
  before_filter :require_no_user, :only => [:show2, :busca]
  before_filter :require_user, :only => [:show, :index, :edit, :create, :update, :dashboard, :enviabusqueda, :buscador, :estadobusqueda, :resultado, :sitios]
  
  layout "bazar"
  def index
    @consultas = Oferta.all.paginate(:page => params[:page], :per_page => 15)
    logger.debug @consultas.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @consultas }
    end
  end

  def list
    @consultas = Oferta.where('1 = 1').order("nombre asc")
    logger.debug @consultas.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @consultas }
    end
  end

  # muestra la información de una consulta para usuarios registrados en bazar 

  def show
    
    @consulta = Oferta.find(params[:id])
    @consultasdatos = Ofertasdato.where("consulta_id = ? and periodo >= ?", params[:id], @consulta.fundada).order("periodo")
    @usuario = User.find(params[:id])
    respond_to do |format|
      format.html { render :action => "show" }
      format.xml  { render :xml => @consulta }
    end

  end

  # muestra la información de una consulta para usuarios no registrados en bazar 
  
  def show2
    @consulta = Oferta.find(params[:id])

    respond_to do |format|
      format.html { render :action => "show2", :layout => false }
      format.xml  { render :xml => @consulta }
    end

  end

  def new
    @consulta = Oferta.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @consulta }
    end
  end

  def edit
    logger.debug "paso por el edit"
    logger.debug params.inspect
    
    if params[:id].to_i != current_user.id.to_i 
      redirect_to("/")
    end 

    @consulta = Oferta.find_by_id(params[:id])
    if (@consulta.nil?) then
      @consulta = Oferta.new
      @consulta.id = params[:id]
      @consulta.user_id = params[:id]
      @consulta.nombre  = 'Escriba su nombre Aquí'
      @consulta.desc    = 'Describa su consulta'
      @consulta.fundada = 2005 
      @consulta.moneda = 0
      @consulta.save
      
    end
    
    $i = @consulta.fundada;
    $num = DateTime.now.year;

# relleno los datos financieros si no existen
    while $i <= $num  do
      @eb = Bazarcms::Ofertasdato.find_by_consulta_id_and_periodo(params[:id], $i)
      
      if (@eb.nil?) then
        @eb = Bazarcms::Ofertasdato.new
        @eb.consulta_id = params[:id];
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
    
    @consultasdatos = Bazarcms::Ofertasdato.where('consulta_id = '+params[:id]+' and periodo >= '+@consulta.fundada.to_s)
    logger.debug "datos de las consultas"
    logger.debug @consulta.inspect
    logger.debug @consultasdatos.inspect

  end

  def create
    logger.debug "pasa por el create "
    logger.debug params.inspect
    @consulta = Oferta.new(params[:bazarcms_consulta])
    @consulta.user_id = current_user.id
    @consulta.id = current_user.id
    @consultasdatos = Bazarcms::Ofertasdato.where('consulta_id = '+params[:id]+' and periodo >= '+@consulta.fundada.to_s)
  
    Actividad.graba("Ha creado una nueva consulta.", "USER", BZ_param("BazarId"), current_user.id, @consulta.nombre)
    
    respond_to do |format|
      if @consulta.save
        logger.debug "se ha creado la consulta:"+@consulta.id.to_s+' '+@consulta.user_id.to_s
        format.html { redirect_to(@consulta, :notice => 'Se ha creado correctamente la consulta.') }
        format.xml  { render :xml => @consulta, :status => :created, :location => @consulta }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @consulta.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    logger.debug params.inspect
    @consulta = Oferta.find(params[:id])
    @consultasdatos = Bazarcms::Ofertasdato.where('consulta_id = '+params[:id]+' and periodo >= '+@consulta.fundada.to_s)
      
    Actividad.graba("Actualizada información consulta.", "USER",  BZ_param("BazarId"), current_user.id, @consulta.nombre)
    
    respond_to do |format|
      if @consulta.update_attributes(params[:bazarcms_consulta])
        # format.html { redirect_to(@consulta, :notice => 'Se ha actualizado correctamente la consulta.') }
        format.html { render :action => "edit" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @consulta.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @consulta = Oferta.find(params[:id])
    
    # las consultas no se borran 
    
    # @consulta.destroy

    respond_to do |format|
      format.html { redirect_to(consultas_url) }
      format.xml  { head :ok }
    end
  end
  
  def dashboard 
    @ultimas = Oferta.ultimascreadas
    @actualizadas = Oferta.ultimasactualizadas
    @total = Oferta.count
    respond_to do |format|
      format.html { render :layout => false }
    end
  end 
  
  def enviabusqueda()
   
   
    @clusters = Cluster.where("activo = 'S'")
    
    @consulta = Ofertasconsulta.new
    @consulta.consulta_id = current_user.id 
    
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

      resultados = Oferta.find_with_ferret(params[:q])
      logger.debug "resu: (#{resultados.inspect}) <-------"
           
      conta2 = 0
      for resu in resultados 


        entra = 0
        total = 0

        # buscamos en los sectores 

        logger.debug "------ Sectores --------------"

        # primero miramos si ofrece lo que buscamos
        
        if params[:pofertan].length > 0
           
          cam = params[:pofertan].split(',')
          
          if cam.count > 0
          
            total += 1

            alguna = 0 
            
            for cc in cam 
              if (cc != "")
                cc2 = cc
                case cc.length
                  when 1
                    cc2 = cc2 + "999"
                  when 2
                    cc2 = cc2 + "99"
                  when 
                    cc2 = cc2 + "9"
                end
                
                datos = Bazarcms::Ofertasperfil.where("consulta_id = ? and tipo = 'O' and codigo between ? and ? ", [resu.id], cc, cc2)
                logger.debug "para #{cc} al #{cc2}-----------> ("+datos.inspect+")"

                if datos.count > 0
                  logger.debug "ENTRA --------> #{datos.count}"
                  alguna += 1
                end 


              end
            end 
            if alguna > 0
              entra += 1 
              logger.debug "Entra en la busqueda de momento"
            end
          end 
        else 
          logger.debug "pofertan viene vacio !!!"
        end 

        # primero miramos si ofrece lo que buscamos
        
        if params[:pdemandan].length > 0
          cam = params[:pdemandan].split(',')
          
          if cam.count > 0
            
            total += 1

            alguna = 0 
            
            for cc in cam 
              if (cc != "")
                cc2 = cc
                case cc.length
                  when 1
                    cc2 = cc2 + "999"
                  when 2
                    cc2 = cc2 + "99"
                  when 
                    cc2 = cc2 + "9"
                end
                
                datos = Bazarcms::Ofertasperfil.where("consulta_id = ? and tipo = 'D' and codigo between ? and ? ", [resu.id], cc, cc2)
                logger.debug "para #{cc} al #{cc2}-----------> ("+datos.inspect+")"

                if datos.count > 0
                  logger.debug "ENTRA --------> #{datos.count}"
                  alguna += 1
                end 

              end
            end 
            if alguna > 0
              entra += 1 
              logger.debug "Entra en la busqueda de momento"
            end
          end 
        else 
          logger.debug "pdemandan viene vacio !!!"
        end 

        
        # buscamos en las ubicaciones 


        # buscamos en la información económica

        # si no pasa los filtros anteriores ni miramos la información económica


        
        datos = Bazarcms::Ofertasdato.where("consulta_id = ?", [resu.id]).order('periodo desc').limit(1)

        logger.debug "datos seleccionados para el filtro #{datos.inspect}"
        # aplicamos el filtro de empleados 

        rangoe = params[:qe].split(' ')
        # puede que existan consultas que todavía no tienen datos!!!!
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
          @res = Ofertasresultado.new(); 
          @res.consultasconsulta_id = @consulta.id
          @res.cluster_id = micluster
          @res.consulta_id = resu.id 
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
     
      if micluster != cluster.id 
        
        logger.debug "Enviando Petición a #{cluster.url}/bazarcms/buscaconsultas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&pofertan="+CGI.escape(params[:pofertan])+"&pdemandan="+CGI.escape(params[:pdemandan])+"&bid=#{@consulta.id}&cid=#{micluster}"
        
        uri = URI.parse("#{cluster.url}/bazarcms/buscaconsultas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&pofertan="+CGI.escape(params[:pofertan])+"&pdemandan="+CGI.escape(params[:pdemandan])+"&bid=#{@consulta.id}&cid=#{micluster}")

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
            consultas = JSON.parse(res.body)

            logger.debug "#{consultas.inspect} <-----------"
            consultas.each{ |key|
              logger.debug("#{key.inspect}")
              logger.debug("#{key['consulta'].inspect} <------ datos")
              resu = Bazarcms::Ofertasresultado.new()
              resu.consultasconsulta_id = @consulta.id
              resu.cluster_id = cluster.id
              resu.consulta_id = key['consulta']['id'] 
              resu.enlace = key['consulta']['url']
              resu.orden = key['consulta']['nombre']
              resu.info = key['consulta']['nombre']
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
      format.html { redirect_to '/bazarcms/consultasconsultas/'+@consulta.id.to_s+'?display=inside'}
    end
    
  end
  
  def buscador
    
  end 

  def busca 

    logger.debug "he recibido una peticion de busqueda #{params.inspect} "
    params[:q] = CGI.unescape(params[:q])
    params[:qe] = CGI.unescape(params[:qe])
    params[:qv] = CGI.unescape(params[:qv])
    params[:qc] = CGI.unescape(params[:qc])
    params[:qr] = CGI.unescape(params[:qr])
    params[:pofertan] = CGI.unescape(params[:pofertan])
    params[:pdemandan] = CGI.unescape(params[:pdemandan])
    
    logger.debug "decodeado #{params[:q]}"
    logger.debug "decodeado #{params[:qe]}"
    logger.debug "decodeado #{params[:qv]}"
    logger.debug "decodeado #{params[:qc]}"
    logger.debug "decodeado #{params[:qr]}"
    logger.debug "decodeado #{params[:pofertan]}"
    logger.debug "decodeado #{params[:demandan]}"
    
    
    
    
    resultados = Oferta.find_with_ferret(params[:q])
    
    logger.debug "#{resultados.inspect}"
    resultados2 = []
    for empre in resultados
      entra = 0
      total = 0
      
      # buscamos en los sectores 

      logger.debug "------ Sectores --------------"

      # primero miramos si ofrece lo que buscamos
      
      if params[:pofertan].length > 0
        cam = params[:pofertan].split(',')
        
        if cam.count > 0
        
          total += 1

          alguna = 0 
          
          for cc in cam 
            if (cc != "")
              cc2 = cc
              case cc.length
                when 1
                  cc2 = cc2 + "999"
                when 2
                  cc2 = cc2 + "99"
                when 
                  cc2 = cc2 + "9"
              end
              
              datos = Bazarcms::Ofertasperfil.where("consulta_id = ? and tipo = 'O' and codigo between ? and ? ", [empre.id], cc, cc2)
              logger.debug "para #{cc} al #{cc2}-----------> ("+datos.inspect+")"

              if datos.count > 0
                logger.debug "ENTRA --------> #{datos.count}"
                alguna += 1
              end 


            end
          end 
          if alguna > 0
            entra += 1 
            logger.debug "Entra en la busqueda de momento"
          end
        end 
      else 
        logger.debug "pofertan viene vacio !!!"
      end 

      # primero miramos si demandan lo que buscamos
      
      if params[:pdemandan].length > 0
        cam = params[:pdemandan].split(',')
        
        if cam.count > 0
          
          total += 1

          alguna = 0 
          
          for cc in cam 
            if (cc != "")
              cc2 = cc
              case cc.length
                when 1
                  cc2 = cc2 + "999"
                when 2
                  cc2 = cc2 + "99"
                when 
                  cc2 = cc2 + "9"
              end
              
              datos = Bazarcms::Ofertasperfil.where("consulta_id = ? and tipo = 'D' and codigo between ? and ? ", [empre.id], cc, cc2)
              logger.debug "para #{cc} al #{cc2}-----------> ("+datos.inspect+")"

              if datos.count > 0
                logger.debug "ENTRA --------> #{datos.count}"
                alguna += 1
              end 

            end
          end 
          if alguna > 0
            entra += 1 
            logger.debug "Entra en la busqueda de momento"
          end
        end 
      else 
        logger.debug "pdemandan viene vacio !!!"
      end 


      
      # buscamos en las ubicaciones
      
      
      
      # miramos los resultados económicos 
      
      datos = Bazarcms::Ofertasdato.where("consulta_id = ?", [empre[:id]]).order('periodo desc').limit(1)
      
      logger.debug "datos seleccionados para el filtro #{datos.inspect}"
      # aplicamos el filtro de empleados 
      
      rangoe = params[:qe].split(' ')
      # puede que existan consultas que todavía no tienen datos!!!!
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
#     logger.debug ("#{cluster.url}/bazarcms/resultadoconsultas?bid=#{params[:bid]}")
#     uri = URI.parse("#{cluster.url}/bazarcms/resultadoconsultas?bid=#{params[:bid]}")

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
    estado = Bazarcms::Ofertasconsulta.where("consulta_id = ?", current_user[:id]).order('fecha_inicio desc').limit(1)
    logger.debug "Estado de la consulta para el usuario #{current_user[:id]}: #{estado.inspect}"
    render :json => estado
  end 
  
  def resultado 
    logger.debug "recibiendo resultado de la busqueda ("+CGI.unescape(params[:bid])+")"
    render :layout => false
  end 

  
end

end

