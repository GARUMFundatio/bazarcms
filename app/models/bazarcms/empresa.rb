module Bazarcms
  
  unloadable
  
  class Empresa < ActiveRecord::Base
    set_table_name "empresas"
    has_many :ubicaciones
    has_many :empresasconsultas
    
    acts_as_taggable
    acts_as_taggable_on :actividades, :intereses
    
    # TODO deberíamos incluir nombre de la ciudad y el pais en la indexación
    
    acts_as_ferret :fields => [ :nombre, :desc, :actividades, :intereses ]
    
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