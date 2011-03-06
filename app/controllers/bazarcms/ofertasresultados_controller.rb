module Bazarcms
  class OfertasdatosController < ApplicationController

  unloadable
  layout "bazar"
  
  def index
    @ofertasdatos = Ofertasdato.all.paginate(:page => params[:page], :per_page => 15)
    puts @ofertasdatos.size
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ofertasdatos }
    end
  end

    def show
      @ofertasdatos = Ofertasdato.find(params[:id])

      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ofertadatos }
      end

    end

    def new
      @ofertasdatos = Ofertasdato.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @ofertasdatos }
      end
    end

    def edit
      puts "paso por el edit"
      puts params.inspect

      @ofertasdatos = Bazarcms::Ofertasdato.find(params[:id])

      puts @ofertasdatos.inspect

    end

    def create
      puts "pasa por el create "
      puts params.inspect
      @ofertasdatos = Ofertasdato.new(params[:bazarcms_ofertasdato])

      respond_to do |format|
        if @ofertasdatos.save
          format.html { redirect_to(@ofertasdatos, :notice => 'creado los datos para este periodo.') }
          format.xml  { render :xml => @ofertasdatos, :status => :created, :location => @ofertasdatos }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @ofertasdatos.errors, :status => :unprocessable_entity }
        end
      end
    end

    def update
      puts params.inspect
      puts "------------"
      @ofertasdatos = Ofertasdato.find(params[:id])
      puts "datos --->"+@ofertasdatos.inspect

      respond_to do |format|
        if @ofertasdatos.update_attributes(params[:bazarcms_ofertasdato])
          format.html { redirect_to(edit_bazarcms_oferta_path(@ofertasdatos.oferta_id)+"#tabs-2") }
          # format.html { render :controller => "ofertas", :action => "edit", :id => @ofertasdatos.oferta_id }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @ofertasdatos.errors, :status => :unprocessable_entity }
        end
      end
    end

    def destroy
      @ofertasdatos = Ofertasdato.find(params[:id])
      @ofertasdatos.destroy

      respond_to do |format|
        format.html { redirect_to(ofertasdatos_url) }
        format.xml  { head :ok }
      end
    end
  
  end

end