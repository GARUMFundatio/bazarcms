module Bazarcms

  class RatingsController < ApplicationController

  unloadable 
  layout "bazar"
  
  def index
    @ratings = Rating.where(' 1 = 1').order('ori_fecha desc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ratings }
    end
  end

  def show

     @rating = Rating.new
     
    # datos de origen 
    
    @rating.ori_empresa_id = current_user.id 
    @rating.ori_bazar_id = BZ_param("BazarId")
    @rating.ori_empresa_nombre = Bazarcms::Empresa.find_by_id(current_user.id).nombre
    
    # datos de destino
     
    @rating.des_empresa_id = params[:empresa_id]
    @rating.des_bazar_id = params[:bazar_id]
    @rating.des_empresa_nombre = params[:empresa_nombre]
    
    # Si la empresa no es de este bazar cogemos los datos de rating 
    # de su bazar y los empotramos en la vista
    
    if (params[:bazar_id].to_i != BZ_param("BazarId").to_i)

      puts "Me traigo la información del rating de su bazar"

      res = dohttpget(params[:bazar_id], "/bazarcms/ficharating/#{params[:empresa_id]}?bazar_id=#{params[:bazar_id]}&display=inside")

      if (res == "")
        res = "Información temporalmente no disponible."
      end

    end
    
    @ratings = Bazarcms::Rating.all

    respond_to do |format|
      if (params[:bazar_id].to_i != BZ_param("BazarId").to_i)
        render :text => res
      else 
        if (params[:display] == "inside")
          render :text => res, :layout => false
        else
          format.html
        end 
      end
      
      format.xml  { render :xml => @rating }
    end


  end

    def new
      
      @rating = Rating.new
      
      # datos de origen 
      
      @rating.ori_empresa_id = current_user.id 
      @rating.ori_bazar_id = BZ_param("BazarId")
      @rating.ori_empresa_nombre = Bazarcms::Empresa.find_by_id(current_user.id).nombre
      
      # datos de destino
       
      @rating.des_empresa_id = params[:empresa_id]
      @rating.des_bazar_id = params[:bazar_id]
      @rating.des_empresa_nombre = params[:empresa_nombre].gsub('_',' ')
      
      @ratings = Bazarcms::Rating.all
      
      respond_to do |format|
        format.html { render }
      end
    end

    def edit
      @rating = Rating.find(params[:id])
      respond_to do |format|
        format.html { render :layout => false }
        format.xml  { render :xml => @rating }
      end
      
    end

    def create
      @rating = Rating.new(params[:bazarcms_rating])

      puts "empresa id: "+params.inspect
      puts "rating : "+@rating.inspect

        # datos generales del rating

        @rating.ori_fecha = DateTime.now
        
        @rating.role = params[:rating]['cliente-proveedor']
        
        @rating.token = rand(99999)+1

        if (@rating.role == 'C')
          
          @rating.ori_cliente_plazos = 0
          @rating.ori_cliente_comunicacion = 0
           
          @rating.ori_proveedor_expectativas = params[:rating][:proveedor_expectativas]
          @rating.ori_proveedor_plazos = params[:rating][:proveedor_plazos]
          @rating.ori_proveedor_comunicacion = params[:rating][:proveedor_comunicacion]
          
          
        else 
          
          @rating.ori_cliente_plazos = params[:rating][:cliente_plazos]
          @rating.ori_cliente_comunicacion = params[:rating][:cliente_comunicacion]
           
          @rating.ori_proveedor_expectativas = 0
          @rating.ori_proveedor_plazos = 0
          @rating.ori_proveedor_comunicacion = 0
                    
        end


      respond_to do |format|
        if @rating.save
          
          @rating.iden = "#{@rating.id}-#{@rating.ori_bazar_id}-#{@rating.ori_empresa_id}"
          @rating.save 
          
          if (@rating.des_bazar_id == BZ_param('BazarId').to_i)
            # TODO: hay que desactivar esto cuando este completo el simétrico 
            
            @rating.calculo(@rating.des_bazar_id, @rating.des_empresa_id)
          else
            # lo enviamos a destino
            logger.debug "Enviando rating a #{@rating.des_bazar_id}"
            dohttppost(@rating.des_bazar_id, "/bazarcms/recrating", @rating.to_json)
          end 
          
          # avisamos con un correo a la empresa destinataria


          if (@rating.des_bazar_id.to_i == BZ_param("BazarId").to_i)

            logger.debug "Es un mensaje con una empresa local!!!"

            emp = Bazarcms::Empresa.find_by_id(current_user.id)
            nombre = emp.nombre

            user = User.find_by_id(params[:empresa])

            para = user.email

            texto = "

            La empresa: #{nombre} ha evaluado su empresa.
            </br>
            Le sugerimos: 
            </br>
            * <a href='#{Cluster.find_by_id(BZ_param('BazarId')).url}/home'>Evalue a la empresa #{nombre}.</a> 
            Esta acción le aparecerá en tareas pendientes. Recuerde que hasta que no evalue a la otra empresa no afectará al rating de las dos empresas.
            </br>
            * <a href='#{Cluster.find_by_id(BZ_param('BazarId')).url}/bazarcms/empresas/#{current_user.id}?bazar_id=#{BZ_param('BazarId')}'>Ver la ficha de empresa de #{nombre}</a>
            </br>
            * <a href='#{Cluster.find_by_id(BZ_param('BazarId')).url}/bazarcms/ficharating/#{current_user.id}?bazar_id=#{BZ_param('BazarId')}'>Ver el rating de #{nombre}</a>
            </br>
            * <a href='#{Cluster.find_by_id(BZ_param('BazarId')).url}/favorito/addfav?bazar=#{BZ_param('BazarId')}&empresa=#{current_user.id}&pre=auto'>Añadir #{nombre} a sus favoritos</a>

            "

            BazarMailer.enviamensaje("#{BZ_param('Titular')} <noreplay@garumfundatio.org>", 
                                        para, 
                                        "#{BZ_param('Titular')}: La empresa #{nombre} ha evaluado su empresa.", 
                                        texto).deliver      

          else  

            emp = Bazarcms::Empresa.find_by_id(current_user.id)
            nombre = emp.nombre

            user = User.find_by_id(current_user.id)
            para = user.email

            @mensaje2 = Mensaje.new()
            @mensaje2.fecha = DateTime.now

            @mensaje2.bazar_origen = BZ_param('BazarId')
            @mensaje2.de = user.id
            @mensaje2.de_nombre = emp.nombre
            @mensaje2.de_email = user.email


            @mensaje2.bazar_destino = @rating.des_bazar_id
            @mensaje2.para = @rating.des_empresa_id

            # Estos datos los coge en remoto

            @mensaje2.para_nombre = "" 
            @mensaje2.para_email = "" 


            @mensaje2.tipo = "M"
            @mensaje2.leido = nil 
            @mensaje2.borrado = nil

            @mensaje2.asunto = "#{BZ_param('Titular')}: La empresa #{nombre} ha evaluado su empresa."
            @mensaje2.texto = "

            <br/>
            La empresa: #{nombre} le ha añadido a sus favoritos.
            </br>
            Le sugerimos: 
            </br>
            * <a href='#{Cluster.find_by_id(@rating.des_bazar_id).url}/home'>Evalue a la empresa #{nombre}.</a> 
            Esta acción le aparecerá en tareas pendientes. Recuerde que hasta que no evalue a la otra empresa no afectará al rating de las dos empresas.
            </br>
            * <a href='#{Cluster.find_by_id(@rating.des_bazar_id).url}/bazarcms/empresas/#{current_user.id}?bazar_id=#{BZ_param('BazarId')}'>Ver la ficha de empresa de #{nombre}</a>
            </br>
            * <a href='#{Cluster.find_by_id(@rating.des_bazar_id).url}/bazarcms/ficharating/#{current_user.id}?bazar_id=#{BZ_param('BazarId')}'>Ver el rating de #{nombre}</a>
            </br>
            * <a href='#{Cluster.find_by_id(@rating.des_bazar_id).url}/favorito/addfav?bazar=#{BZ_param('BazarId')}&empresa=#{current_user.id}&pre=auto'>Añadir #{nombre} a sus favoritos</a>

            "


            logger.debug "Enviando el mensaje a #{@mensaje2.bazar_destino}"

            dohttppost(@mensaje2.bazar_destino, "/mensajeremoto", @mensaje2.to_json)

            @mensaje2.destroy

          end

          Actividad.graba("Ha evaluado la empresa: <a href='#{Cluster.find_by_id(@rating.des_bazar_id).url}/bazarcms/empresas/#{@rating.des_empresa_id}?bazar_id=#{@rating.des_bazar_id}'>#{@rating.des_empresa_nombre.gsub('_',' ')}</a>.", "USER",  BZ_param("BazarId"), current_user.id, nombre)

          # forzamos que se actulicen los caches relacionados con favoritos. 


          expire_fragment "bazar_favoritos_dash_#{current_user.id}"
          expire_fragment "ofertasdash"
          expire_fragment "bazar_actividades_dashboard"

          
          
          expire_fragment "bazar_actividades_dashboard"
          
          
          
          # actualizamos cuando se ha actualizado la empresa para que además se reindexe
          @empresa = Bazarcms::Empresa.find_by_id(current_user.id)          
          
          # @empresa.updated_at = DateTime.now 
          # @empresa.save
          
          format.html { redirect_to('/bazarcms/ficharating/'+"#{@rating.des_empresa_id}?bazar_id=#{@rating.des_bazar_id}") }
          format.xml  { render :xml => @rating, :status => :created, :location => @rating }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @rating.errors, :status => :unprocessable_entity }
        end
      end
    end

    def update
      @rating = Rating.find(params[:id])
      
      respond_to do |format|
        if @rating.update_attributes(params[:bazarcms_rating])
          
          @empresa = Bazarcms::Empresa.find_by_id(current_user.id)

          if !@rating.ciudad.nil?
              Actividad.graba("Actualizada ubicación: '#{@rating.desc}' <a href='#{ciudades_path+'/'+@rating.ciudad.friendly_id}'>#{@rating.ciudad.descripcion}</a> - <a href='#{paises_path+'/'+@rating.ciudad.pais.friendly_id}'>#{@rating.ciudad.pais.descripcion}</a>",
                  "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)

        	else
            Actividad.graba("Actualizada ubicación: #{@rating.desc}", "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)
        	end
          
          # invalidamos los caches para que aparezca la oferta inmediatamente en la home page

          expire_fragment "bazar_actividades_dashboard"
          
          # actualizamos cuando se ha actualizado la empresa para que además se reindexe
          
          @empresa.updated_at = DateTime.now 
          @empresa.save
          
          format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'#tabs-3') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @rating.errors, :status => :unprocessable_entity }
        end
      end
    end

    # TODO proteger todos los destroy para que solo puedan ser ejecutados por un usuarios 
    # en este caso cuestionarse si debe existir incluso la opción de borrado 
    
    def destroy
      @rating = Rating.find(params[:id])
      # TODO no se puede borrar un rating @rating.destroy

      respond_to do |format|
        format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'#tabs-3') }
        format.xml  { head :ok }
      end
    end

    def sendrating
      
      logger.debug "Voy a enviar el rating ---> #{params[:id]}"
      
      @rating = Rating.find_by_id(params[:id])
      
      if (!@rating.nil?)
        logger.debug "rating ----> #{@rating.inspect}"
        if (@rating.des_bazar_id.to_i != BZ_param('BazarId').to_i)
          logger.debug "Enviando rating a #{@rating.des_bazar_id}"
          dohttppost(@rating.des_bazar_id, "/bazarcms/recrating", @rating.to_json)
        else 
          logger.debug "el rating #{params[:id]} era un rating local"
        end
      else 
        logger.debug "ufff no existe este rating" 
      end 
     end 

    def recrating
      
      logger.debug "Rating remoto <-----------"
      body = request.body.read
      logger.debug ">>>#{body}<<<"

      r = JSON.parse(body)
      
      logger.debug "Rating: #{r.inspect}"
      
      rat = Rating.find_by_iden_and_token(r['rating']['iden'], r['rating']['token'])
      if (rat.nil?)
        logger.debug "No parece que exista con estos datos: #{r['rating']['iden']} - #{r['rating']['token']}"
        rat = Rating.new(r['rating'])
        rat.id = 0
        rat.save 
      else 
        logger.debug "rat: #{rat.inspect}"
      end 
            
    end 



    def ficha
      # @rating = Rating.find(params[:id])
      
      if (params[:bazar_id].to_i != BZ_param("BazarId").to_i)

        puts "Me traigo la información del rating de su bazar"

        res = dohttpget(params[:bazar_id], "/bazarcms/ficharating/#{params[:id]}?bazar_id=#{params[:bazar_id]}&display=inside")

        if (res == "")
          res = "Información temporalmente no disponible."
        end

      else 
      
        @empresa = Empresa.find_by_id(params[:id])
  
        # comprobar si este query era el optimo
        # @ratings = Rating.where("(ori_empresa_id = ? and ori_bazar_id = ? ) or (des_empresa_id = ? and des_bazar_id = ? ) ", 
        #  params[:id], BZ_param("BazarId"), params[:id], BZ_param("BazarId")).order("updated_at")

        @ratings = Bazarcms::Rating.where('1 = 1').order('ori_fecha desc')
        
      end


      respond_to do |format|
        if (params[:bazar_id].to_i != BZ_param("BazarId").to_i)
          format.html {render :text => res, :layout => 'bazar'}
        else 
          if (params[:display] == "inside")
            format.html { render :layout => false }
          else
            format.html
          end 
        end

      end
        
    end


  end

end