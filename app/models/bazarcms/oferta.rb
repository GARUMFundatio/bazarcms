module Bazarcms
  
  unloadable

  class Oferta < ActiveRecord::Base

    set_table_name "ofertas"

    # TODO establecer bien las relaciones
    
    belongs_to :empresa
  
    def self.mostrada(bazar_id, oferta_id)
    
      oferta = Bazarcms::Oferta.find_by_bazar_id_and_id(bazar_id, oferta_id) 
      if (!oferta.nil?)
        
        oferta.vistas += 1
        oferta.save
        
        # TODO: actualizar en remoto si oferta es de otro bazar 
        
      end
      
    end 
  
  
  end

end