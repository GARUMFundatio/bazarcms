module Bazarcms

  class EmpresasresultadosController < ApplicationController

  unloadable 
  layout "bazar"
  
  # TODO controlar que las consultas son solo las realizadas por un usuario 
  # registrado 
  
  def index
    @empresasresultados = Empresasresultado.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @empresasresultado }
    end
  end
  
  def show
   
    @consulta = Empresasconsulta.find_by_empresa_id_and_id(current_user.id, params[:id])
    @empresasresultados = Empresasresultado.where('empresasconsulta_id = ?', params[:id]).order('orden').paginate(:page => params[:page], :per_page => 30)

    if request.xhr?
      render(:partial => "empresasresultado", :collection => @empresasresultados)
    end

  end

end 

end