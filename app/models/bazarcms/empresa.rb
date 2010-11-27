module Bazarcms
  
  unloadable
  
  
  class Empresa < ActiveRecord::Base
    set_table_name "empresas"

    acts_as_taggable
    acts_as_taggable_on :actividades, :intereses

    scope :ultimascreadas, order("empresas.created_at DESC").limit(5)
    scope :ultimasactualizadas, order("empresas.updated_at DESC").limit(5)
    
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