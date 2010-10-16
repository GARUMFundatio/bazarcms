module Bazarcms
  class Empresasdato < ActiveRecord::Base
    set_table_name "empresasdatos"

    def make
      puts "hecho bazarcms empresas datos"
    end
    
  end
end