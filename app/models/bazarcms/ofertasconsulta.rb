module Bazarcms
  
  unloadable

  class Ofertasconsulta < ActiveRecord::Base
    set_table_name "ofertasconsultas"
    
    belongs_to :ofertas
    has_many :ofertasresultados
       
  end

end