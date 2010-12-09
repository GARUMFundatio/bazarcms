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

      respond_to do |format|
        format.html { render :layout => false }
        format.xml  { render :xml => @ubicacion }
      end
    end

    def edit
      @ubicacion = Ubicacion.find(params[:id])
      
    end

    def create
      @ubicacion = Ubicacion.new(params[:bazarcms_ubicacion])
      @ubicacion.empresa_id = params[:empresa]

      puts "empresa id: "+params.inspect
      puts "ubicacion : "+@ubicacion.inspect

      respond_to do |format|
        if @ubicacion.save
          format.html { redirect_to(@ubicacion, :notice => 'Ubicacion was successfully created.') }
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
          format.html { redirect_to(@ubicacion, :notice => 'Ubicacion was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @ubicacion.errors, :status => :unprocessable_entity }
        end
      end
    end

    def destroy
      @ubicacion = Ubicacion.find(params[:id])
      @ubicacion.destroy

      respond_to do |format|
        format.html { redirect_to(ubicaciones_url) }
        format.xml  { head :ok }
      end
    end
  end

end