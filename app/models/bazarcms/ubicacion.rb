module Bazarcms
  
  unloadable

class Ubicacion < ActiveRecord::Base
    
  belongs_to :empresa
  set_table_name "ubicaciones"
  
end

end