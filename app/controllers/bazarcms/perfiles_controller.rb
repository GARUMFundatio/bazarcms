module Bazarcms

  class PerfilesController < ApplicationController

  unloadable 
  layout "bazar"
  
  def busqueda
    @perfiles = Perfil.limit(20).where('lower(`desc`) like ? OR lower(ayuda) like ?', '%'+params[:term].downcase+'%', '%'+params[:term].downcase+'%').order('codigo')
    puts @perfiles.inspect
    respond_to do |format|
      format.json {
         @info = []
         for perfil in @perfiles
           @info << {:label => "#{perfil.codigo}:#{perfil.desc}", :value => "#{perfil.desc}", :id => "#{perfil.codigo}"}
         end
         render :json =>  @info  }
    end
    
  end
  
  # mostramos la lista de perfiles de una empresa y del tipo que nos llega
  
  def listaperfiles
    @perfiles =  Empresasperfil.where('empresa_id = ? and tipo = ?', current_user.id, params[:tipo]).order('codigo')
    render :layout => false 
  end

  # añadimos a la empresa el perfil seleccionado
  
  def addperfil
    
    @perfil =  Empresasperfil.new
    
    @perfil.codigo = params[:codigo]
    @perfil.empresa_id = current_user.id
    @perfil.tipo = params[:tipo]
    @perfil.save 
    
    redirect_to('/bazarcms/listaperfiles?tipo='+params[:tipo])
     
  end
  
  # añadimos a la empresa el perfil seleccionado
  
  def delperfil
    
    @perfil =  Empresasperfil.find_by_empresa_id_and_tipo_and_codigo(current_user.id, params[:tipo], params[:codigo])
    logger.debug "#{@perfil.inspect}"
    @perfil.destroy
    
    redirect_to('/bazarcms/listaperfiles?tipo='+params[:tipo])
     
  end
  
 
 end

end