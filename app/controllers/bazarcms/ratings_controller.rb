module Bazarcms

  class RatingsController < ApplicationController

  unloadable 
  layout "bazar"
  
  def index
    @ratings = Rating.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ratings }
    end
  end

    def show
      @rating = Rating.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @rating }
      end
    end

    def new
      
      @rating = Rating.new
      
      @rating.ori_empresa_id = params[:ori_empresa_id]
      
      # datos generales del rating
      
      @rating.fecha = DateTime.now
      @rating.role = 'C'
      @rating.token = rand(99999)+1
      
      # datos de origen 
      
      @rating.ori_empresa_id = current_user.id 
      @rating.ori_bazar_id = BZ_param("BazarId")
      @rating.ori_empresa_nombre = Bazarcms::Empresa.find_by_id(current_user.id).nombre
      
      # datos de destino
       



      
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

      respond_to do |format|
        if @rating.save
          
          @rating.iden = "#{rating.id}-#{rating.ori_bazar_id}-#{rating.ori_empresa_id}"
          
          
          @empresa = Bazarcms::Empresa.find_by_id(current_user.id)          
          
          # if !@rating.ciudad.nil?
          #    Actividad.graba("Nueva ubicación: '#{@rating.desc}' <a href='#{ciudades_path+'/'+@rating.ciudad.friendly_id}'>#{@rating.ciudad.descripcion}</a> - <a href='#{paises_path+'/'+@rating.ciudad.pais.friendly_id}'>#{@rating.ciudad.pais.descripcion}</a>",
          #        "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)

        	# else
          #  Actividad.graba("Nueva ubicación: #{@rating.desc}", "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)
        	# end
          
          # invalidamos los caches para que aparezca la oferta inmediatamente en la home page

          expire_fragment "bazar_actividades_dashboard"
          
          
          # actualizamos cuando se ha actualizado la empresa para que además se reindexe
          
          # @empresa.updated_at = DateTime.now 
          # @empresa.save
          
          format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'#tabs-3') }
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
      @rating.destroy

      respond_to do |format|
        format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'#tabs-3') }
        format.xml  { head :ok }
      end
    end
  end

end