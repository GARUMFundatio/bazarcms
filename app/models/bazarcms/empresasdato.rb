module Bazarcms
  
  unloadable
  
  class Empresasdato < ActiveRecord::Base
    set_table_name "empresasdatos"

    def self.RangoEmpleados
        {
         "1-2"      => "0", 
         "3-5"      => "1", 
         "6-9"      => "2", 
         "10-19"    => "3", 
         "20-49"    => "4", 
         "50-99"    => "5", 
         "100-199"  => "6", 
         "200-499"  => "7", 
         "500-999"  => "8", 
         "1000-4999" => "9", 
         "+ 5000"   => "10"       
         }
    end

    def make
      puts "hecho bazarcms empresas datos"
    end
    
  end
end