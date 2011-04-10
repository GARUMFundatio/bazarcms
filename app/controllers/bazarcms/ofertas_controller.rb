module Bazarcms
  
  class OfertasController < ApplicationController
  require "net/http"
  require "uri"
  
  unloadable
  before_filter :require_no_user, :only => [:show2, :busca]
  before_filter :require_user, :only => [:index, :edit, :create, :update, :dashboard, :enviabusqueda, :buscador, :estadobusqueda, :resultado, :sitios]
  
  layout "bazar"
  def index

    @ofertas = Oferta.where("1 = 1").order("fecha desc").paginate(:per_page => 30, :page => params[:page])

    if request.xhr?
      render :partial => 'oferta', :collection => @ofertas
    end

  end

  def list
    @ofertas = Oferta.where('1 = 1').order("nombre asc")
    logger.debug @ofertas.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ofertas }
    end
  end

  # muestra la información de una oferta para usuarios registrados en bazar 

  def show
        
    if ( params[:bazar_id].to_i == BZ_param("BazarId").to_i )
      
      @oferta = Oferta.find(params[:id])
      @oferta.clicks += 1
      @oferta.save 

      @infoempresa = dohttpget(params[:bazar_id], "/bazarcms/empresas/#{@oferta.empresa_id}?bazar_id=#{@oferta.bazar_id}&display=inside")
      # @infoempresa = ""
      if (@infoempresa == "")
        @infoempresa = ""
      end
      
      respond_to do |format|
        if !params[:display].nil? 

          if params[:display] == "inside"
            format.html { render :action => "show", :layout => false }
          end 

        else 

          format.html { render :action => "show" }

        end 

      end
    
    else 
      
      res = dohttpget(params[:bazar_id], "/bazarcms/ofertas/#{params[:id]}?bazar_id=#{params[:bazar_id]}&display=inside")
      
      if (res == "")
        res = "Información temporalmente no disponible."
      end
      
      
      #  @infoempresa = dohttpget(params[:bazar_id], "/bazarcms/empresas/#{params[:id]}?bazar_id=#{params[:bazar_id]}&display=inside")
      
      # if (@infoempresa == "")
      #   @infoempresa = "Información temporalmente no disponible."
      # end
      
      
      render :text => res, :layout => 'bazar'
      
    end 


  end

  # muestra la información de una oferta para usuarios no registrados en bazar 
  
  def show2
    @oferta = Oferta.find(params[:id])

    respond_to do |format|
      format.html { render :action => "show2", :layout => false }
      format.xml  { render :xml => @oferta }
    end

  end

  def new
    @oferta = Oferta.new

    logger.debug @oferta.inspect
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @oferta }
    end
  end

  def edit
    logger.debug "paso por el edit"
    logger.debug params.inspect
    
    @oferta = Oferta.find_by_id(params[:id])
    
    if @oferta.empresa_id.to_i != current_user.id.to_i
        redirect_to('/')
    end 
    
    $i = @oferta.fundada;
    $num = DateTime.now.year;

    logger.debug "datos de las ofertas"
    logger.debug @oferta.inspect

  end

  def create
    
    logger.debug "pasa por el create "
    logger.debug "------------>"+params.inspect
    @oferta = Oferta.new(params[:bazarcms_oferta])
    @oferta.empresa_id = current_user.id
    @oferta.bazar_id = BZ_param("BazarId")
    
    if (params[:tipo] == "oferta")
      @oferta.tipo = "O"
    else 
      @oferta.tipo = "D"
    end 
    
    fe = params[:bazarcms_oferta][:fecha].split('/')
    @oferta.fecha = fe[2]+'-'+fe[1]+'-'+fe[0]
    
    fe = params[:bazarcms_oferta][:fecha_hasta].split('/')
    @oferta.fecha_hasta = fe[2]+'-'+fe[1]+'-'+fe[0]
    
    # grabamos la información de la oferta. 
    
    @oferta.vistas = 0
    @oferta.clicks = 0
    @oferta.contactos = 0
    @oferta.fav_empresa = 0
    @oferta.fav_oferta = 0
    @oferta.publica = "Preparando la publicación."
    
    @oferta.save

    # guardamos la información extendida para facilitar las busquedas avanzadas.
    
    filtro = params[:bazarcms_oferta][:filtro].split('&')
    
    for fil in filtro
    
      logger.debug "filtro (#{fil})"
      cam = fil.split('=')  

        if (cam[0] == 'pofertan' ||cam[0] == 'pdemandan' )
          if (!cam[1].nil?)
            for sec in cam[1].split(',')
              logger.debug "sec (#{sec})"  
              @perfil = Ofertasperfil.new
              @perfil.consulta_id = @oferta.id
              @perfil.codigo = sec
              if (cam[0] == 'pofertan')
                @perfil.tipo = 'O'
              else 
                @perfil.tipo = 'D'          
              end
              @perfil.save
            end
          end 
        end
    
    end 
      
    
    # anotamos la actividad en local
    
    Actividad.graba("Ha creado una nueva oferta.", "USER", BZ_param("BazarId"), current_user.id, @oferta.titulo)
    
    respond_to do |format|
      if @oferta.save
        logger.debug "se ha creado la oferta:"+@oferta.id.to_s+' '+@oferta.empresa_id.to_s
        format.html { render :layout => true }
        format.xml  { render :xml => @oferta, :status => :created, :location => @oferta }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @oferta.errors, :status => :unprocessable_entity }
      end
    end
  end
  

  def update
    logger.debug params.inspect
    @oferta = Oferta.find(params[:id])
    
    Actividad.graba("Actualizada información oferta.", "USER",  BZ_param("BazarId"), current_user.id, @oferta.nombre)
    
    respond_to do |format|
      if @oferta.update_attributes(params[:bazarcms_oferta])
        # format.html { redirect_to(@oferta, :notice => 'Se ha actualizado correctamente la oferta.') }
        format.html { render :action => "edit" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @oferta.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @oferta = Oferta.find(params[:id])
    
    # las ofertas no se borran 
    
    # @oferta.destroy

    respond_to do |format|
      format.html { redirect_to(ofertas_url) }
      format.xml  { head :ok }
    end
  end
  

  def enviabusqueda()
   
   
    @clusters = Cluster.where("activo = 'S'")
    
    @oferta = Ofertasoferta.new
    @oferta.oferta_id = current_user.id 
    
    logger.debug "------> (#{params[:q]}) unscaped (#{CGI.unescape(params[:q])})"
    logger.debug "------> (#{params.inspect})"
    
    @oferta.desc = CGI.unescape(params[:q])
    @oferta.total_ofertas = @clusters.count()
    @oferta.total_respuestas = 0
    @oferta.total_resultados = 0
    @oferta.fecha_inicio = DateTime::now
    @oferta.fecha_fin = nil
    @oferta.sql = params[:q]
    @oferta.save
    
    conta = 0
    micluster = BZ_param("BazarId").to_i;
    logger.debug "ID de mi cluster #{micluster} <------"
    
    # primero buscamos en local para ofrecer los primeros resultados antes
    
      logger.debug "busco en local"
      conta += 1 
      
      @oferta.total_respuestas = @oferta.total_respuestas + 1;
      @oferta.save

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
                
                datos = Bazarcms::Ofertasperfil.where("oferta_id = ? and tipo = 'O' and codigo between ? and ? ", [resu.id], cc, cc2)
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
                
                datos = Bazarcms::Ofertasperfil.where("oferta_id = ? and tipo = 'D' and codigo between ? and ? ", [resu.id], cc, cc2)
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


        
        datos = Bazarcms::Ofertasdato.where("oferta_id = ?", [resu.id]).order('periodo desc').limit(1)

        logger.debug "datos seleccionados para el filtro #{datos.inspect}"
        # aplicamos el filtro de empleados 

        rangoe = params[:qe].split(' ')
        # puede que existan ofertas que todavía no tienen datos!!!!
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
          @res.ofertasoferta_id = @oferta.id
          @res.cluster_id = micluster
          @res.oferta_id = resu.id 
          @res.orden = resu.nombre
          @res.enlace = resu.url
          @res.info = "#{resu.nombre}"
          @res.save
          conta2 += 1
        end 

         
      end 
      @oferta.total_resultados = @oferta.total_resultados + conta2;
      @oferta.save 
    


    # luego lanzamos las busquedas al resto de los bazares

    for cluster in @clusters
     
      if micluster != cluster.id 
        
        logger.debug "Enviando Petición a #{cluster.url}/bazarcms/buscaofertas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&pofertan="+CGI.escape(params[:pofertan])+"&pdemandan="+CGI.escape(params[:pdemandan])+"&bid=#{@oferta.id}&cid=#{micluster}"
        
        uri = URI.parse("#{cluster.url}/bazarcms/buscaofertas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&pofertan="+CGI.escape(params[:pofertan])+"&pdemandan="+CGI.escape(params[:pdemandan])+"&bid=#{@oferta.id}&cid=#{micluster}")

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
            ofertas = JSON.parse(res.body)

            logger.debug "#{ofertas.inspect} <-----------"
            ofertas.each{ |key|
              logger.debug("#{key.inspect}")
              logger.debug("#{key['oferta'].inspect} <------ datos")
              resu = Bazarcms::Ofertasresultado.new()
              resu.ofertasoferta_id = @oferta.id
              resu.cluster_id = cluster.id
              resu.oferta_id = key['oferta']['id'] 
              resu.enlace = key['oferta']['url']
              resu.orden = key['oferta']['nombre']
              resu.info = key['oferta']['nombre']
              resu.save
              conta2 += 1
              }
            
            @oferta.total_respuestas = @oferta.total_respuestas + 1;
            @oferta.total_resultados = @oferta.total_resultados + conta2;
            @oferta.save
          else
            logger.debug "ERROR en la petición a #{uri}---------->"+res.error!
          end
        
        rescue Exception => e
          logger.debug "Exception leyendo #{cluster.url} Got #{e.class}: #{e}"        
        end
        
      end
               

    end 
    
    @oferta.total_ofertas = conta;
    @oferta.fecha_fin = DateTime::now

    @oferta.save

    respond_to do |format|
      format.html { redirect_to '/bazarcms/ofertasofertas/'+@oferta.id.to_s+'?display=inside'}
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
              
              datos = Bazarcms::Ofertasperfil.where("oferta_id = ? and tipo = 'O' and codigo between ? and ? ", [empre.id], cc, cc2)
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
              
              datos = Bazarcms::Ofertasperfil.where("oferta_id = ? and tipo = 'D' and codigo between ? and ? ", [empre.id], cc, cc2)
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
      
      datos = Bazarcms::Ofertasdato.where("oferta_id = ?", [empre[:id]]).order('periodo desc').limit(1)
      
      logger.debug "datos seleccionados para el filtro #{datos.inspect}"
      # aplicamos el filtro de empleados 
      
      rangoe = params[:qe].split(' ')
      # puede que existan ofertas que todavía no tienen datos!!!!
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
#     logger.debug ("#{cluster.url}/bazarcms/resultadoofertas?bid=#{params[:bid]}")
#     uri = URI.parse("#{cluster.url}/bazarcms/resultadoofertas?bid=#{params[:bid]}")

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
    estado = Bazarcms::Ofertasoferta.where("oferta_id = ?", current_user[:id]).order('fecha_inicio desc').limit(1)
    logger.debug "Estado de la oferta para el usuario #{current_user[:id]}: #{estado.inspect}"
    render :json => estado
  end 
  
  def resultado 
    logger.debug "recibiendo resultado de la busqueda ("+CGI.unescape(params[:bid])+")"
    render :layout => false
  end 

  def dashboard 
    
    @ofertas = Oferta.where("1 = 1").order("fecha desc").limit(5)
    @total = Oferta.count_by_sql("select count(*) from ofertas ;")

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

end

end

