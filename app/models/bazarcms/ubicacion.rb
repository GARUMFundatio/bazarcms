module Bazarcms
  
  unloadable

  class Ubicacion < ActiveRecord::Base
    set_table_name "ubicaciones"
    
    belongs_to :empresa
    belongs_to :ciudad
        
  end

end