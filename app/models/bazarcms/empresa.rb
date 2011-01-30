module Bazarcms
  
  unloadable
  
  class Empresa < ActiveRecord::Base
    set_table_name "empresas"
    has_many :ubicaciones
    has_many :empresasconsultas
    
    acts_as_taggable
    acts_as_taggable_on :actividades, :intereses
    
    # TODO deberíamos incluir nombre de la ciudad y el pais en la indexación
    
    acts_as_ferret :fields => [ :nombre, :desc, :actividades, :intereses, :sitios ]
    
    scope :ultimascreadas, order("empresas.created_at DESC").limit(5)
    scope :ultimasactualizadas, order("empresas.updated_at DESC").limit(5)
        
    def sitios
      tmp = []
      for ubi in ubicaciones
        tmp << ubi.desc
        tmp << ubi.ciudad.descripcion
        tmp << ubi.ciudad.pais.descripcion
      end
      return tmp
    end
    
    def self.Monedas
        {
         "Euro" => "0", 
         "USD"  => "1"       
         }
    end
    
    def self.Monedastexto(ind)
      self.Monedas.each do |k,v| 
        if v.to_i == ind 
          return k
        end
      end
      return "No definido"
    end 
    
    def make
      puts "hecho bazarcms empresas"
    end
    
  end
end