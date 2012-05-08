module Bazarcms
  
  class EmpresasController < ApplicationController
  require "net/http"
  require "uri"
  require "typhoeus"
  
  unloadable
  before_filter :require_no_user, :only => [:busca]
  before_filter :require_user, :only => [:index, :edit, :create, :update, :dashboard, :enviabusqueda, :buscador, :estadobusqueda, :resultado, :sitios]
  
  layout "bazar"
  def index
    @empresas = Empresa.where('1 = 1').order("nombre asc")
    logger.debug @empresas.size
    respond_to do |format|
      format.html # index.html.erb
      # TODO: devolver un listado de empresas en formato xml y json con la información que decidamos
      # format.xml  { render :xml => @empresas }
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
    
    # TODO limitar el acceso a bots o no, pero hay que tomar una decisión. 
    
    # si la empresa es local extraemos la información de la base de datos
    # si de otro bazar la pedimos al bazar
    puts "Bazar #{BZ_param("BazarId").to_i} -> #{params[:bazar_id].to_i}"
    if ( params[:bazar_id].to_i == BZ_param("BazarId").to_i )
      
      @empresa = Empresa.find(params[:id])
      @empresasdatos = Empresasdato.where("empresa_id = ? and periodo >= ?", params[:id], @empresa.fundada).order("periodo")
      @usuario = User.find(params[:id])
    
      respond_to do |format|
        if !params[:display].nil? 
          if params[:display] == "inside"
            format.html { render :action => "show", :layout => false }
          end 
        else 
          format.html { render :action => "show" }
        end 
        format.xml  { render :xml => @empresa }
      end
    
    else 
      
      puts "empresa de otro bazar"
      
      if params[:display].nil? 
        params[:display] = ""
        puts "no viene display"
      end 
      
      if params[:display] == "inside"
        puts "Es para pintar inside"
        res = dohttpget(params[:bazar_id], "/bazarcms/empresas/#{params[:id]}?bazar_id=#{params[:bazar_id]}&display=inside&user_id=#{current_user.id}")

        if (res == "")
          res = "Información temporalmente no disponible."
        end

        render :text => res, :layout => false
        
      else 
        puts "lo pinto con el layout"
        res = dohttpget(params[:bazar_id], "/bazarcms/empresas/#{params[:id]}?bazar_id=#{params[:bazar_id]}&display=inside&user_id=#{current_user.id}")

        if (res == "")
          res = "Información temporalmente no disponible."
        end

        render :text => res, :layout => 'bazar'

      end          

    end         

  end

  # muestra la información de una empresa para usuarios no registrados en bazar 
  
  def show2
    @empresa = Empresa.find(params[:id])

    respond_to do |format|
      format.html { render :action => "show2", :layout => true }
      format.xml  { render :xml => @empresa }
    end

  end

  def new
    # TODO: @empresa = Empresa.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @empresa }
    end
  end

  def edit
    logger.debug "paso por el edit"
    logger.debug params.inspect
    
    if params[:id].to_i != current_user.id.to_i 
      redirect_to("/")
    end 

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
    
    if !@empresa.fundada.nil? 
      $i = @empresa.fundada
    else
      $i = DateTime.now.year
      @empresa.fundada = DateTime.now.year
      @empresa.save
    end
    
    $num = DateTime.now.year

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
    @empresasdatos = Bazarcms::Empresasdato.where('empresa_id = '+current_user.id.to_s+' and periodo >= '+@empresa.fundada.to_s)
      
    Actividad.graba("Actualizada información empresa.", "USER",  BZ_param("BazarId"), current_user.id, @empresa.nombre)
    
    respond_to do |format|
      if @empresa.update_attributes(params[:bazarcms_empresa])
        # format.html { redirect_to(@empresa, :notice => 'Se ha actualizado correctamente la empresa.') }
        format.html { redirect_to "/bazarcms/empresas/#{@empresa.id}/edit"}
      else
        format.html { redirect_to "/bazarcms/empresas/#{@empresa.id}/edit?bazar_id=#{BZ_param("BazarId")}" }
      end
    end
  end

  def destroy
    @empresa = Empresa.find(params[:id])
    
    # las empresas no se borran 
    
    # @empresa.destroy

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

      if (params[:q] == '*')
        resultados = Empresa.where('1 =1').order('rating desc').limit(100)
      else 
        resultados = Empresa.find_with_ferret(params[:q], :limit => :all)        
      end
      
      logger.debug "resu: (#{resultados.inspect}) <-------"
           
      conta2 = 0
      for resu in resultados
        
        next if resu.nombre =~ /^Escriba /
        
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
                
                datos = Bazarcms::Empresasperfil.where("empresa_id = ? and tipo = 'O' and codigo between ? and ? ", [resu.id], cc, cc2)
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
                
                datos = Bazarcms::Empresasperfil.where("empresa_id = ? and tipo = 'D' and codigo between ? and ? ", [resu.id], cc, cc2)
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
                
                datos = Bazarcms::Ubicacion.where("empresa_id = ? ", [resu.id])
                
                if datos.count > 0
                  for ubi in datos
                    if !ubi.ciudad.nil?
                      if (ubi.ciudad.pais.id == cc.to_i)
                        logger.debug "ENTRA --------> #{ubi.ciudad.descripcion}"
                        alguna += 1
                      end
                    else 
                      logger.debug "NO ENTRA --------> No tiene país #{ubi.ciudad.descripcion}"
                    end
                  end
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


        # buscamos en la información económica

        # si no pasa los filtros anteriores ni miramos la información económica
        
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
          
          num = resu.rating * 1000 + ( resu.rating_total_cliente + resu.rating_total_proveedor)
          
          @res.orden = "#{num}"
          @res.enlace = resu.url
          @res.info = "#{resu.nombre}"
          @res.save
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
              
        uri = "#{cluster.url}/bazarcms/buscaempresas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&pofertan="+CGI.escape(params[:pofertan])+"&pdemandan="+CGI.escape(params[:pdemandan])+"&ppaises="+CGI.escape(params[:ppaises])+"&bid=#{@consulta.id}&cid=#{micluster}"
        logger.debug "Enviando Petición a ------------> #{uri}"

        r = Typhoeus::Request.new(uri, :timeout => 5000)
        r.on_complete do |response|
          logger.debug "-------------> "+response.inspect
          case response.curl_return_code
          when 0
            conta += 1
            conta2 = 0
            
            begin
              empresas = JSON.parse(response.body)

              logger.debug "#{empresas.inspect} <-----------"
              cluster_id = 0 
              empresas.each{ |key|
                logger.debug("#{key.inspect}")
                if !key['cluster_id'].nil?
                  logger.debug "viene un cluster id "+key.inspect
                  cluster_id = key['cluster_id']
                end
                if !key['empresa'].nil?
                  logger.debug("#{key['empresa'].inspect} <------ datos")
                  resu = Bazarcms::Empresasresultado.new()
                  resu.empresasconsulta_id = @consulta.id
                  resu.cluster_id = cluster_id
                  resu.empresa_id = key['empresa']['id'] 
                  resu.enlace = key['empresa']['url']
                  num = key['empresa']['rating'].to_i * 1000 + ( key['empresa']['rating_total_cliente'].to_i + key['empresa']['rating_total_proveedor'].to_i)
                  resu.orden = "#{num}"
                  resu.info = key['empresa']['nombre']
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
    @esta.consulta = "q="+params[:q]+"&qe="+params[:qe]+"&qv="+params[:qv]+"&qc="+params[:qc]+"&qr="+params[:qr]+"&pofertan="+params[:pofertan]+"&pdemandan="+params[:pdemandan]+"&ppaises="+params[:ppaises]+"&bid=#{@consulta.id}&cid=#{micluster}"
    @esta.empresas =  @consulta.total_resultados
    @esta.empresa_id = current_user.id
    @esta.tipo = 'B'
    @esta.save


    respond_to do |format|
      if params[:display] == "total"
        format.html { render :layout => false}
      else
        format.html { redirect_to '/bazarcms/empresasconsultas/'+@consulta.id.to_s+'?display=inside'}      
      end
    
    end
    
  end
  
  def buscador
    
  end 


  def hydra 
     
     # creamos una cola de peticiones http
     
     hydra = Typhoeus::Hydra.new
     
     logger.debug "lanzo las peticiones "+DateTime.now.to_s
     
     1.times do
       r = Typhoeus::Request.new("http://bazar.garumfundatio.org/api/info.xml")
       r.on_complete do |response|
         logger.debug "-------------> "+response.inspect
       end
       hydra.queue r

       r = Typhoeus::Request.new("http://bazargarum.dyndns.org:3000/bazarcms/buscaempresas?q=%2A&qe=0+10&qv=0+10&qc=0+10&qr=0+10&pofertan=&pdemandan=&bid=422&cid=2", :timeout       => 3000)
       r.on_complete do |response|
         logger.debug "-------------> "+response.inspect
       end
       hydra.queue r

     end

     logger.debug "encoladas "+DateTime.now.to_s
     
     hydra.run

     logger.debug "servidas "+DateTime.now.to_s
     
     
  end 
  
  def busca 

    logger.debug "he recibido una peticion de busqueda #{params.inspect} "
    params[:q] = CGI.unescape(params[:q])
    params[:qe] = CGI.unescape(params[:qe])
    if params[:qe].nil?
      params[:qe] = "0 10"
    end
    params[:qv] = CGI.unescape(params[:qv])
    if params[:qv].nil?
      params[:qv] = "0 10"
    end
    params[:qc] = CGI.unescape(params[:qc])
    if params[:qc].nil?
      params[:qc] = "0 10"
    end
    params[:qr] = CGI.unescape(params[:qr])
    if params[:qr].nil?
      params[:qr] = "0 10"
    end

    params[:pofertan] = CGI.unescape(params[:pofertan])
    params[:pdemandan] = CGI.unescape(params[:pdemandan])
    params[:ppaises] = CGI.unescape(params[:ppaises])
    
    logger.debug "q  decodeado #{params[:q]}"
    logger.debug "qe decodeado #{params[:qe]}"
    logger.debug "qv decodeado #{params[:qv]}"
    logger.debug "qc decodeado #{params[:qc]}"
    logger.debug "qr decodeado #{params[:qr]}"
    logger.debug "pofertan  decodeado #{params[:pofertan]}"
    logger.debug "pdemandan decodeado #{params[:pdemandan]}"
    logger.debug "ppaises   decodeado #{params[:ppaises]}"
        
    if (params[:q] == '*')
      resultados = Empresa.where('1 =1').order('rating desc').limit(100)
    else 
      resultados = Empresa.find_with_ferret(params[:q], :limit => :all)        
    end
    
    logger.debug "#{resultados.inspect}"
    resultados2 = []
    resultados2 = [:cluster_id => BZ_param('BazarId')]
    
    for empre in resultados
      entra = 0
      total = 0
      
      next if empre.nombre =~ /^Escriba /
      
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
              
              datos = Bazarcms::Empresasperfil.where("empresa_id = ? and tipo = 'O' and codigo between ? and ? ", [empre.id], cc, cc2)
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

      # primero miramos si demandan lo que buscamos
      
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
              
              datos = Bazarcms::Empresasperfil.where("empresa_id = ? and tipo = 'D' and codigo between ? and ? ", [empre.id], cc, cc2)
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

        cam = params[:ppaises].split(/ |,/)
        
        if cam.count > 0
          
          for cc in cam 
            if (cc != "")
              ubis = Bazarcms::Ubicacion.where("empresa_id = ? ", empre.id)
              for ubi in ubis 
                logger.debug "cc: "+cc
                next if ubi.ciudad.nil?
                logger.debug "ubi: "+ubi.inspect 
                next if ubi.ciudad.pais.nil?
                logger.debug "pais: "+ubi.ciudad.pais.inspect 
                 
                next if ubi.ciudad.pais.codigo.nil?
                
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
      
      # miramos los resultados económicos 
      
      datos = Bazarcms::Empresasdato.where("empresa_id = ?", [empre[:id]]).order('periodo desc').limit(1)
      
      logger.debug "datos seleccionados para el filtro #{datos.inspect}"
      # aplicamos el filtro de empleados 
      
      rangoe = params[:qe].split(' ')
      # puede que existan empresas que todavía no tienen datos!!!!
      if (!datos.nil?)
        if datos[0].empleados >= rangoe[0].to_i && datos[0].empleados <= rangoe[1].to_i
          entra += 1
        else 
          logger.debug "empleados #{datos[0].empleados} no está en el rango #{rangoe[0].to_i} - #{rangoe[1].to_i}"
        end
      end
      total+=1
      
      rangoc = params[:qc].split(' ')
      if (!datos.nil?)
        if datos[0].compras >= rangoc[0].to_i && datos[0].compras <= rangoc[1].to_i
          entra += 1 
        else 
          logger.debug "compras #{datos[0].compras} no está en el rango #{rangoc[0].to_i} - #{rangoc[1].to_i}"          
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
      
      rangor = params[:qr].split(' ')
      if (!datos.nil?)
        if datos[0].resultados >= rangor[0].to_i && datos[0].resultados <= rangor[1].to_i
          entra += 1 
        else 
          logger.debug "resultados #{datos[0].resultados} no está en el rango #{rangor[0].to_i} - #{rangor[1].to_i}"          
        end
      end
      total+=1
      
      if (entra == total)
        resultados2 << empre
      else 
        logger.debug "No entra por datos económicos!!!"
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
    @esta.tipo = 'B'
    
    @esta.save
   
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

