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

end
end