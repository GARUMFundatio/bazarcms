module Bazarcms
  
  class OfertasController < ApplicationController
  require "net/http"
  require "uri"
  
  unloadable
  before_filter :require_no_user, :only => [:show2, :busca]
  before_filter :require_user, :only => [:index, :edit, :create, :update, :dashboard, :enviabusqueda, :buscador, :estadobusqueda, :resultado, :sitios]
  
  layout "bazar"
  
  def index

    # @ofertas = Oferta.where("1 = 1").order("fecha desc").paginate(:per_page => 30, :page => params[:page])

    @ofertas = Ofertasresultado.select("cluster_id, oferta_id, empresa_id, info, orden").where("oferta_id is not null").group("cluster_id, oferta_id").order("orden desc").paginate(:per_page => 30, :page => params[:page])

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
      if !@oferta.nil? 
        if !@oferta.clicks.nil?
          @oferta.clicks += 1
        else 
          @oferta.clicks = 1
        end 
        @oferta.save 
      end 
      # @infoempresa = dohttpget(params[:bazar_id], "/bazarcms/empresas/#{@oferta.empresa_id}?bazar_id=#{@oferta.bazar_id}&display=inside")
      # @infoempresa = ""
      #if (@infoempresa == "")
      #  @infoempresa = ""
      # end
      
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

        # información de los sectores a los que está dirigida la oferta
        
        if (cam[0] == 'pofertan' ||cam[0] == 'pdemandan' )
          if (!cam[1].nil?)
            for sec in cam[1].split(',')
              logger.debug "sec (#{sec})"  
              @perfil = Ofertasperfil.new
              @perfil.oferta_id = @oferta.id
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
    
        if (cam[0] == 'ppaises' )
          if (!cam[1].nil?)
            for sec in cam[1].split(',')
              logger.debug "sec (#{sec})"  
              @pais = Ofertaspais.new
              @pais.oferta_id = @oferta.id
              @pais.codigo = sec
              @pais.save
            end
          end 
        end


    end 
      
    
    # anotamos la actividad en local
    
    @empresa = Bazarcms::Empresa.find_by_id(current_user.id)
    if @oferta.tipo == 'O'
      Actividad.graba("Nueva oferta: <a href='#{bazarcms_oferta_path(@oferta.id, :bazar_id => @oferta.bazar_id)}'>#{@oferta.titulo}</a>", "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)
    else 
      Actividad.graba("Nueva Demanda: <a href='#{bazarcms_oferta_path(@oferta.id, :bazar_id => @oferta.bazar_id)}'>#{@oferta.titulo}</a>", "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)      
    end 
    
    # invalidamos los caches para que aparezca la oferta inmediatamente en la home page
    
    expire_fragment "bazar_favoritos_dash_#{current_user.id}"
    expire_fragment "ofertasdash"
    expire_fragment "bazar_actividades_dashboard"
    
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
    
    @consulta = Ofertasconsulta.new
    @consulta.empresa_id = current_user.id 
    
    logger.debug "------> (#{params[:q]}) unscaped (#{CGI.unescape(params[:q])})"
    logger.debug "------> (#{params.inspect})"
    
    @consulta.desc = CGI.unescape(params[:q])
    @consulta.total_consultas = @clusters.count()
    @consulta.total_respuestas = 0
    @consulta.total_resultados = 0
    @consulta.fecha_inicio = DateTime::now
    @consulta.fecha_fin = nil
    
    # TODO: deberíamos meter todo el query para luego interpretarlo
     
    @consulta.sql = params[:q]
    @consulta.save
    
    conta = 0
    micluster = ApplicationController.BZ_param("BazarId").to_i
    logger.debug "ID de mi cluster #{micluster} <------"
    
    # primero buscamos en local para ofrecer los primeros resultados antes
    
      logger.debug "busco en local"
      conta += 1 
      
      @consulta.total_respuestas = @consulta.total_respuestas + 1
      @consulta.save
      
      if (params[:q] == '*')
        resultados = Oferta.where('1 = 1').order('fecha desc').limit(100)
      else 
        resultados = Oferta.find_with_ferret(params[:q], :limit => :all)        
      end
      
      logger.debug "resu: (#{resultados.inspect}) <-------"
           
      conta2 = 0
      for resu in resultados 

        if resu.tipo != params[:qtipo]
          next
        end 
           
        entra = 0
        total = 0

        # buscamos en los sectores 

        logger.debug "------ Sectores --------------"

        # primero miramos si ofrece lo que buscamos
        
        if params[:pofertan].length > 0
          total += 1
          alguna = 0 
                     
          cam = params[:pofertan].split(',')
          
          if cam.count > 0
          
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
                
                datos = Bazarcms::Ofertasperfil.where("oferta_id = ? and tipo = 'O' and codigo between ? and ? ", resu.id, cc, cc2)
                logger.debug "para #{cc} al #{cc2}-----------> ("+datos.inspect+")"

                if datos.count > 0
                  logger.debug "ENTRA --------> #{datos.count}"
                  alguna += 1
                end 


              end
            end 
          end 
          if alguna > 0
            entra += 1 
            logger.debug "Entra en la busqueda de momento: total #{total} entra #{entra}"
          end
        else 
          logger.debug "pofertan viene vacio !!!"
        end 

        # primero miramos si ofrece lo que buscamos
        
        if params[:pdemandan].length > 0
          total += 1
          alguna = 0
           
          cam = params[:pdemandan].split(',')
          
          if cam.count > 0
            
            
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
                
                datos = Bazarcms::Ofertasperfil.where("oferta_id = ? and tipo = 'D' and codigo between ? and ? ", resu.id, cc, cc2)
                logger.debug "para #{cc} al #{cc2}-----------> ("+datos.inspect+")"

                if datos.count > 0
                  logger.debug "ENTRA --------> #{datos.count}"
                  alguna += 1
                end 

              end
            end 
          end 
          
          if alguna > 0
            entra += 1 
            logger.debug "Entra en la busqueda de momento: total #{total} entra #{entra}"
          end
          
        else 
          logger.debug "pdemandan viene vacio !!!"
        end 

        
        # buscamos en las ubicaciones 

        
        if params[:ppaises].length > 0
          total += 1
          alguna = 0 

          cam = params[:ppaises].split(',')
          
          if cam.count > 0
            
            for cc in cam 
              if (cc != "")
                
                # TODO: en ofertaspaises deberíamos grabar los paises para ahora poder hacer la consulta bien
                logger.debug "Paises que buscamos -------> #{resu.id} #{cc}"
                paises = Bazarcms::Ofertaspais.where("oferta_id = ? and codigo = ? ", resu.id, cc)
                
                if paises.count > 0
                  logger.debug "ENTRA esta oferta por pais --------> #{paises.inspect}"
                  alguna += 1                
                end 
              end
            end 
          end 
          
          if alguna > 0
            entra += 1 
            logger.debug "Entra en la busqueda de momento: total #{total} entra #{entra}"
          end
        else 
          logger.debug "ppaises viene vacio !!!"
        end 


        if (entra == total)
          @res = Ofertasresultado.new(); 
          @res.ofertasconsulta_id = @consulta.id
          @res.cluster_id = micluster
          @res.empresa_id = resu.empresa_id
          @res.oferta_id = resu.id
          @res.tipo = resu.tipo
          @res.nombre_empresa = "poner nombre bien"
                     
          @res.orden = resu.fecha
          @res.enlace = "poner el enlace bien" # resu.url
          @res.info = "#{resu.titulo}"
          @res.save
          
          # increment views counter 
          
          resu.vistas += 1 
          resu.save 
          
          conta2 += 1
        end 
         
      end 
      @consulta.total_resultados = @consulta.total_resultados + conta2;
      @consulta.save 
    
    # luego lanzamos las busquedas al resto de los bazares

    hydra = Typhoeus::Hydra.new
    
    logger.debug "lanzo las peticiones "+DateTime.now.to_s
    
    for cluster in @clusters
     
      if micluster != cluster.id 
              
        uri = "#{cluster.url}/bazarcms/buscaofertas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&pofertan="+CGI.escape(params[:pofertan])+"&pdemandan="+CGI.escape(params[:pdemandan])+"&ppaises="+CGI.escape(params[:ppaises])+"&qtipo="+CGI.escape(params[:qtipo])+"&bid=#{@consulta.id}&cid=#{micluster}"
        logger.debug "Enviando Petición a ------------> #{uri}"

        r = Typhoeus::Request.new(uri, :timeout => 5000)
        r.on_complete do |response|
          logger.debug "-------------> "+response.inspect
          case response.curl_return_code
          when 0
            conta += 1
            conta2 = 0
            
            begin
              ofertas = JSON.parse(response.body)

              logger.debug "#{ofertas.inspect} <-----------"
              cluster_id = 0 
              ofertas.each{ |key|
                logger.debug("#{key.inspect}")
                if !key['cluster_id'].nil?
                  logger.debug "viene un cluster id "+key.inspect
                  cluster_id = key['cluster_id']
                end
                if !key['oferta'].nil?
                  logger.debug("#{key['oferta'].inspect} <------ datos")
                  
                  resu = Bazarcms::Ofertasresultado.new()    
                  resu.ofertasconsulta_id = @consulta.id
                  resu.cluster_id = cluster_id
                  resu.oferta_id = key['oferta']['id']
                  resu.tipo =  key['oferta']['tipo']
                  resu.empresa_id = key['oferta']['empresa_id'] 
                  resu.nombre_empresa = "poner nombre bien"
                  resu.enlace = "Poner el enlace bien 2" # key['oferta']['url']
                  resu.orden = key['oferta']['fecha'] # .strftime('%Y%m%d%H%M')
                  resu.info = key['oferta']['titulo']
                  resu.save
                  conta2 += 1
                end
                }
            
              @consulta.total_respuestas = @consulta.total_respuestas + 1;
              @consulta.total_resultados = @consulta.total_resultados + conta2;
              @consulta.save
            rescue 
              logger.debug "El JSON: venía mal formado #{response.body}"
              
            end 
          else
            logger.debug "ERROR en la petición ---------->"+response.inspect
          end

        end

        hydra.queue r        
     
      end

    end 

    hydra.run

    logger.debug "servidas "+DateTime.now.to_s

    @consulta.total_consultas = conta;
    @consulta.fecha_fin = DateTime::now

    @consulta.save

    # grabamos una entrada para las estadísticas de consultas
    
    @esta = Estadisticasconsulta.new
    
    @esta.fecha = DateTime.now
    @esta.bazar_id = BZ_param("BazarId")
    @esta.consulta = "q="+params[:q]+"&qe="+params[:qe]+"&qv="+params[:qv]+"&qc="+params[:qc]+"&qr="+params[:qr]+"&pofertan="+params[:pofertan]+"&pdemandan="+params[:pdemandan]+"&ppaises="+params[:ppaises]+"&qtipo="+params[:qtipo]+"&bid=#{@consulta.id}&cid=#{micluster}"
    @esta.empresas =  @consulta.total_resultados
    @esta.empresa_id = current_user.id
    @esta.tipo = params[:qtipo]
    @esta.save

    respond_to do |format|
      if params[:display] == "total"
        format.html { render :layout => false}
      else
        format.html { redirect_to '/bazarcms/ofertasconsultas/'+@consulta.id.to_s+'?display=inside'}      
      end
    
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
      params[:ppaises] = CGI.unescape(params[:ppaises])
      params[:qtipo] = CGI.unescape(params[:qtipo])

      logger.debug "decodeado #{params[:q]}"
      logger.debug "decodeado #{params[:qe]}"
      logger.debug "decodeado #{params[:qv]}"
      logger.debug "decodeado #{params[:qc]}"
      logger.debug "decodeado #{params[:qr]}"
      logger.debug "decodeado #{params[:pofertan]}"
      logger.debug "decodeado #{params[:pdemandan]}"
      logger.debug "decodeado #{params[:ppaises]}"
      logger.debug "decodeado #{params[:qtipo]}"

      if (params[:q] == '*')
        resultados = Oferta.where('1 = 1').order('fecha desc').limit(100)
      else 
        resultados = Oferta.find_with_ferret(params[:q], :limit => :all)        
      end
     
      logger.debug "#{resultados.inspect}"
      resultados2 = []
      resultados2 = [:cluster_id => BZ_param('BazarId')]

      for ofe in resultados
        
        if ofe.tipo != params[:qtipo]
          next
        end 
        
        entra = 0
        total = 0

        # comprobamos si la empresa está en los limites de búsqueda
        
        datos = Bazarcms::Empresasdato.where("empresa_id = ?", ofe.empresa_id).order('periodo desc').limit(1)

        logger.debug "datos seleccionados para el filtro #{datos.inspect}"
        
        # aplicamos el filtro de empleados 

        rangoe = params[:qe].split(' ')

        if (!datos.nil?)
          if datos[0].empleados >= rangoe[0].to_i && datos[0].empleados <= rangoe[1].to_i
            entra += 1
          else 
            logger.debug "empleados #{datos[0].empleados} no está en el rango #{rangoe[0].to_i} - #{rangoe[1].to_i}"
          end
        end

        total+=1

        rangov = params[:qv].split(' ')
        if (!datos.nil?)
          if datos[0].ventas >= rangov[0].to_i && datos[0].ventas <= rangov[1].to_i
            entra += 1 
          else 
            logger.debug "ventas #{datos[0].ventas} no está en el rango #{rangov[0].to_i} - #{rangov[1].to_i}"          

          end
        end
        total+=1
        
        # buscamos en los sectores 

        logger.debug "------ Sectores --------------"

        # primero miramos si ofrece lo que buscamos

        if params[:pofertan].length > 0
          total += 1
          alguna = 0 

          cam = params[:pofertan].split(',')

          if cam.count > 0

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

                datos = Bazarcms::Ofertasperfil.where("oferta_id = ? and tipo = 'O' and codigo between ? and ? ", ofe.id, cc, cc2)
                logger.debug "para #{cc} al #{cc2}-----------> ("+datos.inspect+")"

                if datos.count > 0
                  logger.debug "ENTRA --------> #{datos.count}"
                  alguna += 1
                end 

              end
            end 
          end 
          if alguna > 0
            entra += 1 
            logger.debug "Entra en la busqueda de momento"
          end
        else 
          logger.debug "pofertan viene vacio !!!"
        end 

        # luego miramos si demandan lo que buscamos

        if params[:pdemandan].length > 0

          total += 1
          alguna = 0 

          cam = params[:pdemandan].split(',')

          if cam.count > 0

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

                datos = Bazarcms::Ofertasperfil.where("oferta_id = ? and tipo = 'D' and codigo between ? and ? ", ofe.id, cc, cc2)
                logger.debug "para #{cc} al #{cc2}-----------> ("+datos.inspect+")"

                if datos.count > 0
                  logger.debug "ENTRA --------> #{datos.count}"
                  alguna += 1
                end 

              end
            end 
          end 
          if alguna > 0
            entra += 1 
            logger.debug "Entra en la busqueda de momento"
          end
        else 
          logger.debug "pdemandan viene vacio !!!"
        end 

        # buscamos en las ubicaciones
        if params[:ppaises].length > 0
          total += 1
          alguna = 0 

          cam = params[:ppaises].split(/,| /)

          if cam.count > 0

            for cc in cam 
              if (cc != "")

                ubis = Bazarcms::Ubicacion.where("empresa_id = ? ", ofe.empresa_id)
                for ubi in ubis 
                  logger.debug "cc: "+cc
                  next if ubi.ciudad.nil? 
                  logger.debug "ubi: "+ubi.inspect 
                  next if ubi.ciudad.pais.nil? 
                  next if ubi.ciudad.pais.codigo.nil?
                  logger.debug "ubi: "+ubi.ciudad.pais.inspect 
                  
                  if ubi.ciudad.pais.codigo == cc 
                    logger.debug "ENTRA por pais --------> #{ubi.inspect}"
                    alguna += 1
                  end
                end

              end
            end 
          end

          if alguna > 0
            entra += 1 
            logger.debug "Entra en la busqueda de momento"
          end

        else 
          logger.debug "ppaises viene vacio !!!"
        end 


        if (entra == total)
          if !ofe.vistas.nil?
            ofe.vistas += 1
          else 
            ofe.vistas = 1
          end 
          
          logger.debug "incrementado vistas ------->  #{ofe.vistas}"
          ofe.save
          resultados2 << ofe
        end 

      end 

      logger.debug "filtrados #{resultados2.inspect}"


      # grabamos una entrada para las estadísticas de consultas

      logger.debug "Grabamos la información para las estadisticas de consultas <--------------"

      @esta = Estadisticasconsulta.new

      @esta.fecha = DateTime.now

      logger.debug "#{params.inspect}"

      @esta.bazar_id = params[:cid]    
      @esta.consulta ="q="+params[:q]+"&qe="+params[:qe]+"&qv="+params[:qv]+"&qc="+params[:qc]+"&qr="+params[:qr]+"&pofertan="+params[:pofertan]+"&pdemandan="+params[:pdemandan]+"&ppaises="+params[:ppaises]+"&bid="+params[:bid]+"&cid="+params[:cid]

      @esta.empresas = resultados2.count
      @esta.empresa_id = 0
      @esta.tipo = params[:qtipo]

      @esta.save

    render :json => resultados2

  end 
  
  
  def estadobusqueda 
    estado = Bazarcms::Ofertasconsulta.where("empresa_id = ?", current_user[:id]).order('fecha_inicio desc').limit(1)
    logger.debug "Estado de la oferta para el usuario #{current_user[:id]}: #{estado.inspect}"
    render :json => estado
  end 
  
  def resultado 
    logger.debug "recibiendo resultado de la busqueda ("+CGI.unescape(params[:bid])+")"
    render :layout => false
  end 

  def dashboard 
 
    @ofertas = Ofertasresultado.select("cluster_id, oferta_id, empresa_id, info, orden").where("oferta_id is not null").group("cluster_id, oferta_id").order("orden desc").limit(5)
    # TODO: revisar el contador total debería funcionar
    # @total = @ofertas.size

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def rss
    @ofertas = Oferta.where("bazar_id = ?", BZ_param('BazarId')).order("fecha desc").limit(100)
    render :layout => false
  end

  def rss2
    @ofertas = Ofertasresultado.select("cluster_id, oferta_id, empresa_id, info, orden").where("oferta_id is not null").group("cluster_id, oferta_id").order("orden desc").limit(300)
    render :layout => false
  end

  
end

end

