module Bazarcms
  class EmpresasDatosController < ApplicationController

  unloadable
  layout "bazar"
  
  def index
    @empresasdatos = Empresadato.all
    puts @empresasdatos.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @empresasdatos }
    end
  end

    def show
      @empresasdatos = Empresadato.find(params[:id])

      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @empresadatos }
      end

    end

    def new
      @empresasdatos = Empresadato.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @empresasdatos }
      end
    end

    def edit
      puts "paso por el edit"
      puts params.inspect

      @empresasdatos = Bazarcms::Empresasdato.find_by_empresa_id(params[:id])

      puts @empresasdatos.inspect

    end

    def create
      puts "pasa por el create "
      puts params.inspect
      @empresasdatos = Empresadato.new(params[:bazarcms_empresasdato])

      respond_to do |format|
        if @empresasdatos.save
          format.html { redirect_to(@empresasdatos, :notice => 'creado los datos para este periodo.') }
          format.xml  { render :xml => @empresasdatos, :status => :created, :location => @empresasdatos }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @empresasdatos.errors, :status => :unprocessable_entity }
        end
      end
    end

    def update
      puts params.inspect
      @empresasdatos = Empresasdato.find(params[:id])

      respond_to do |format|
        if @empresa.update_attributes(params[:bazarcms_empresasdatos])
          # format.html { redirect_to(@empresa, :notice => 'Se ha actualizado correctamente la empresa.') }
          format.html { render :action => "edit" }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @empresasdatos.errors, :status => :unprocessable_entity }
        end
      end
    end

    def destroy
      @empresasdatos = Empresadato.find(params[:id])
      @empresasdatos.destroy

      respond_to do |format|
        format.html { redirect_to(empresasdatos_url) }
        format.xml  { head :ok }
      end
    end
  
  end

end