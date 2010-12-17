module Bazarcms

  class EmpresasconsultasController < ApplicationController

  unloadable 
  layout "bazar"
  
  # TODO controlar que las consultas son solo las realizadas por un usuario 
  # registrado 
  
  def index
    @empresasconsultas = Empresasconsulta.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @empresasconsultas }
    end
  end

end 

end
