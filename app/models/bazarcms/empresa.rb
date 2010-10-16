module Bazarcms
  class Empresa < ActiveRecord::Base
    set_table_name "empresas"

    def make
      puts "hecho bazarcms empresas"
    end
    
  end
end