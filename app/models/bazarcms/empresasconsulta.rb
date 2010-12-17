module Bazarcms
  
  unloadable

  class Empresasconsulta < ActiveRecord::Base
    set_table_name "empresasconsultas"
    
    belongs_to :empresa
    has_many :empresasresultados
       
  end

end