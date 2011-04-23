module Bazarcms
  
  unloadable

  # TODO: incluir sectores y paises 
  
  class Oferta < ActiveRecord::Base

    set_table_name "ofertas"

    # TODO establecer bien las relaciones
    
    belongs_to :empresa
  
    acts_as_ferret :fields => [ :titulo, :texto ]
    
    has_friendly_id :titulo, :use_slug => true, :approximate_ascii => true
    
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