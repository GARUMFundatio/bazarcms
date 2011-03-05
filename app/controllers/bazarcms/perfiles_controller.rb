module Bazarcms

  class PerfilesController < ApplicationController

  unloadable 
  layout "bazar"
  
  def busqueda
    
    # @perfiles = Perfil.limit(20).where('lower(`desc`) like ? OR lower(ayuda) like ?', '%'+params[:term].downcase+'%', '%'+params[:term].downcase+'%').order('codigo')
   
   terms = params[:term].split(' ')
   
   condi = []
   condi << ""
   tmp = ""
   for term in terms 
     
     if (tmp.length == 0)
       tmp = '(`codigo` like ? OR lower(`desc`) like ? OR lower(ayuda) like ? ) '
     else
       tmp += 'AND (`codigo` like ? OR lower(`desc`) like ? OR lower(ayuda) like ? ) '
     end
     condi << '%'+term+'%'
     condi << '%'+term+'%' 
     condi << '%'+term+'%' 
   end
   condi[0] = tmp
   
   puts "Condiciones de busqueda -----> #{condi.inspect}"
   
   @perfiles = Perfil.find(:all, :conditions => condi, :order => 'codigo', :limit => 20)
    
   puts @perfiles.inspect
   
   
    respond_to do |format|
      format.json {
         @info = []
         for perfil in @perfiles
           @info << {:label => "#{perfil.codigo}:#{perfil.desc}", :value => "#{perfil.desc}", :id => "#{perfil.codigo}", :ayuda => "#{perfil.ayuda.sub(/.*\n/,'').gsub(/\n/,'<br/>')}"}
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
    
    @perfil = Empresasperfil.find_by_codigo_and_tipo_and_empresa_id(params[:codigo], params[:tipo], current_user.id)
    if @perfil.nil?
      @perfil =  Empresasperfil.new
    
      @perfil.codigo = params[:codigo]
      @perfil.empresa_id = current_user.id
      @perfil.tipo = params[:tipo]
      @perfil.save 
    end 
  
    # creamos un nuevo registro de actividad 
    
    @empresa = Bazarcms::Empresa.find_by_id(current_user.id)
    
    Actividad.graba("Ha añadido un nuevo sector en su perfil: #{@perfil.codigo}-#{Bazarcms::Perfil.find_by_codigo(@perfil.codigo).desc }", 
    "USER", BZ_param("BazarId"), current_user.id, @empresa.nombre)
    
    
    # actualizamos cuando se ha actualizado la empresa para que además se reindexe
    
    @empresa.updated_at = DateTime.now 
    @empresa.save
    
    
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