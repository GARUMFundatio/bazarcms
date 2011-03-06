module Bazarcms
  
  unloadable

  class Oferta < ActiveRecord::Base

    set_table_name "ofertas"

    # TODO establecer bien las relaciones
    
    belongs_to :empresa
  
  end

end