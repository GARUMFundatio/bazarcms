module Bazarcms
  class EmpresasController < ApplicationController

    unloadable
    
    layout 'bazarcms' 
    
    def index
    end
    
    def show
    end
    
    def edit 
        # TODO aquí debieramos dejar que administrador y quizas el 
        # animador puedan cambiar/mejorar la info la empresa 
        
        @empresa = Empresa.find_by_user_id(params[:id])
        if (@empresa.nil?) then
          @empresa = Empresa.new
          @empresa.user_id = params[:id]
          @empresa.nombre  = 'Escriba su nombre Aquí'
          @empresa.desc    = 'Describa su empresa'
          @empresa.fundada = 2010 
        end 
    end
    
    def save 
    
    end
    
  end
end