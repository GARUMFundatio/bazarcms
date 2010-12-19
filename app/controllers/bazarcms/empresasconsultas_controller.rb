module Bazarcms

  class EmpresasconsultasController < ApplicationController

  unloadable 
  layout "bazar"
  
  # TODO controlar que las consultas son solo las realizadas por un usuario 
  # registrado 
  
  def index
    @empresasconsultas = Empresasconsulta.where('empresa_id = ?', current_user.id).order('fecha_inicio desc').paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @empresasconsultas }
    end
  end
 
  def estado
    @consulta = Empresasconsulta.where('id = ?', params[:id])
      
    respond_to do |format|
      format.html 
    end
    
  end
  
  def show 
    @consulta = Empresasconsulta.find_by_empresa_id_and_id(current_user.id, params[:id])
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
    
    @empresasconsultas = Empresasconsulta.where('empresa_id = ?', current_user.id)  
    for empre in @empresasconsultas
      puts "borrando #{empre.id}"
      empre.empresasresultados.delete
      empre.delete
    end
    
    respond_to do |format|
      format.html { redirect_to('/bazarcms/buscadorempresas') }
      format.xml  { render :xml => @empresasconsultas }
    end
      
  end 
  
  def destroy
    
    @empresasconsultas = Empresasconsulta.find_by_empresa_id_and_id(current_user.id, params[:id])
    puts "#{@empresasconsultas.inspect} <----------------"
    if (@empresasconsultas.total_resultados != 0)
      @empresasconsultas.empresasresultados.destroy 
    end
    @empresasconsultas.destroy

    respond_to do |format|
      format.html { redirect_to(bazarcms_empresasconsultas_url) }
      format.xml  { head :ok }
    end
  end

end 

end
