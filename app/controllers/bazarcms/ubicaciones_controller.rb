module Bazarcms

  class UbicacionesController < ApplicationController

  unloadable 
  layout "bazar"
  
  def index
    @ubicaciones = Ubicacion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ubicaciones }
    end
  end

    def show
      @ubicacion = Ubicacion.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @ubicacion }
      end
    end

    def new
      @ubicacion = Ubicacion.new
      @ubicacion.empresa_id = params[:empresa]
      respond_to do |format|
        format.html { render :layout => false }
        format.xml  { render :xml => @ubicacion }
      end
    end

    def edit
      @ubicacion = Ubicacion.find(params[:id])
      respond_to do |format|
        format.html { render :layout => false }
        format.xml  { render :xml => @ubicacion }
      end
      
    end

    def create
      @ubicacion = Ubicacion.new(params[:bazarcms_ubicacion])

      puts "empresa id: "+params.inspect
      puts "ubicacion : "+@ubicacion.inspect

      respond_to do |format|
        if @ubicacion.save
          format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'?tab=ubicaciones') }
          format.xml  { render :xml => @ubicacion, :status => :created, :location => @ubicacion }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @ubicacion.errors, :status => :unprocessable_entity }
        end
      end
    end

    def update
      @ubicacion = Ubicacion.find(params[:id])
      
      respond_to do |format|
        if @ubicacion.update_attributes(params[:bazarcms_ubicacion])
          
          Actividad.graba("Actualizada ubicación: #{@ubicacion.desc}", "USER", BZ_param("BazarId"), current_user.id)

          format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'?tab=ubicaciones') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @ubicacion.errors, :status => :unprocessable_entity }
        end
      end
    end

    # TODO proteger todos los destroy para que solo puedan ser ejecutados por un usuarios 
    # en este caso cuestionarse si debe existir incluso la opción de borrado 
    
    def destroy
      @ubicacion = Ubicacion.find(params[:id])
      @ubicacion.destroy

      respond_to do |format|
        format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'?tab=ubicaciones') }
        format.xml  { head :ok }
      end
    end
  end

end