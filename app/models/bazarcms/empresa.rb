module Bazarcms
  
  unloadable
  
  class Empresa < ActiveRecord::Base
    set_table_name "empresas"

    def self.Monedas
        {
         "Euro" => "0", 
         "USD"  => "1"       
         }
    end
    
    def make
      puts "hecho bazarcms empresas"
    end
    
  end
end