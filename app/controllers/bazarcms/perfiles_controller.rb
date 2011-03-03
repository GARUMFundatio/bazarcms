module Bazarcms

  class PerfilesController < ApplicationController

  unloadable 
  layout "bazar"
  
  def index
    @perfiles = Perfil.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @perfiles }
    end
  end

    def show
      @perfil = Perfil.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @perfil }
      end
    end

    def new
      @perfil = Perfil.new
      @perfil.empresa_id = params[:empresa]
      respond_to do |format|
        format.html { render :layout => false }
        format.xml  { render :xml => @perfil }
      end
    end

    def edit
      @perfil = Perfil.find(params[:id])
      respond_to do |format|
        format.html { render :layout => false }
        format.xml  { render :xml => @perfil }
      end
      
    end

    def create
      @perfil = Perfil.new(params[:bazarcms_ubicacion])

      puts "empresa id: "+params.inspect
      puts "ubicacion : "+@perfil.inspect

      respond_to do |format|
        if @perfil.save
          format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'?tab=ubicaciones') }
          format.xml  { render :xml => @perfil, :status => :created, :location => @perfil }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @perfil.errors, :status => :unprocessable_entity }
        end
      end
    end

    def update
      @perfil = Perfil.find(params[:id])
      
      respond_to do |format|
        if @perfil.update_attributes(params[:bazarcms_ubicacion])
          @empresa = Bazarcms::Empresa.find_by_id(current_user.id)
          Actividad.graba("Actualizada ubicación: #{@perfil.desc}", "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)

          format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'?tab=ubicaciones') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @perfil.errors, :status => :unprocessable_entity }
        end
      end
    end

    # TODO proteger todos los destroy para que solo puedan ser ejecutados por un usuarios 
    # en este caso cuestionarse si debe existir incluso la opción de borrado 
    
    def destroy
      @perfil = Perfil.find(params[:id])
      @perfil.destroy

      respond_to do |format|
        format.html { redirect_to(edit_bazarcms_empresa_url(current_user.id)+'?tab=ubicaciones') }
        format.xml  { head :ok }
      end
    end
  end

end