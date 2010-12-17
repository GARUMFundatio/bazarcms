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

end 

end