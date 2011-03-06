module Bazarcms

  class OfertasconsultasController < ApplicationController

  unloadable 
  layout "bazar"
  
  # TODO controlar que las consultas son solo las realizadas por un usuario 
  # registrado 
  
  def index
    @ofertasconsultas = Ofertasconsulta.where('oferta_id = ?', current_user.id).order('fecha_inicio desc').paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @ofertasconsultas }
    end
  end
 
  def estado
    @consulta = Ofertasconsulta.find_by_id(params[:id])
    puts "#{@consulta.inspect} --> #{params.inspect}"  
    respond_to do |format|
      format.html { render :layout => false }
    end
    
  end
  
  def show 
    @consulta = Ofertasconsulta.find_by_oferta_id_and_id(current_user.id, params[:id])
    puts "Consulta: #{@consulta.inspect} <------"
    respond_to do |format|
      format.html { 
        if params[:display] == 'inside' 
          render :layout => false
        else 
          render 
        end 
       }
      format.xml  { render :xml => @consulta }
    end
    
  end 

  def borrartodas
    
    @ofertasconsultas = Ofertasconsulta.where('oferta_id = ?', current_user.id)  
    for empre in @ofertasconsultas
      puts "borrando #{empre.id}"
      empre.ofertasresultados.delete
      empre.delete
    end
    
    respond_to do |format|
      format.html { redirect_to('/bazarcms/buscadorofertas') }
      format.xml  { render :xml => @ofertasconsultas }
    end
      
  end 
  
  def destroy
    
    @ofertasconsultas = Ofertasconsulta.find_by_oferta_id_and_id(current_user.id, params[:id])
    puts "#{@ofertasconsultas.inspect} <----------------"
    if (@ofertasconsultas.total_resultados != 0)
      @ofertasconsultas.ofertasresultados.destroy 
    end
    @ofertasconsultas.destroy

    respond_to do |format|
      format.html { redirect_to(bazarcms_ofertasconsultas_url) }
      format.xml  { head :ok }
    end
  end

end 

end
