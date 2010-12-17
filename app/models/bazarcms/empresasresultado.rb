module Bazarcms
  
  unloadable

  class Empresasresultado < ActiveRecord::Base
    set_table_name "empresasresultados"

    belongs_to :empresasconsulta
        
  end

end