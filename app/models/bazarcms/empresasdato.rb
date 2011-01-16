module Bazarcms
  
  unloadable
  
  class Empresasdato < ActiveRecord::Base
    set_table_name "empresasdatos"

    def self.RangoEmpleados
        {
         "1-2"      => 0, 
         "3-5"      => 1, 
         "6-9"      => 2, 
         "10-19"    => 3, 
         "20-49"    => 4, 
         "50-99"    => 5, 
         "100-199"  => 6, 
         "200-499"  => 7, 
         "500-999"  => 8, 
         "1000-4999" => 9, 
         "+ 5000"   => 10       
         }
    end

    def self.REtexto(ind)
      self.RangoEmpleados.each do |k,v| 
        if v == ind 
          return k
        end
      end
      return "No definido"
    end 

    def self.listaRE
      lista = "
      var listaRE = [];
      var listaRE2 = [];
      var maxRE = 0;
      "
      max = 0;
      
      self.RangoEmpleados.each do |k,v|
        if v > max 
          max = v
        end
        cam = k.split('-')
        if cam.count == 1 
          cam << cam[0]
        end
        lista += "listaRE[#{v}] = '#{cam[0]}';
        listaRE2[#{v}] = '#{cam[1]}';
        "
      end
      
      lista += "
      maxRE = #{max};
      "
      return lista
    end 


    def self.RangoDatos
        {
         "0-0.5 M"    => 0,
         "0.6-0.9 M"  => 1,
         "1-2 M"      => 2, 
         "3-5 M"      => 3, 
         "6-9 M"      => 4, 
         "10-19 M"    => 5, 
         "20-49 M"    => 6, 
         "50-99 M"    => 7, 
         "100-199 M"  => 8, 
         "200-499 M"  => 9, 
         "+ 500 M"  => 10
         }
    end
    
    
    def self.RDtexto(ind)
      self.RangoDatos.each do |k,v| 
        if v == ind 
          return k
        end
      end
      return "No definido"
    end 

    def self.listaRD
      lista2 = "
      var listaRD = [];
      var listaRD2 = [];
      var maxRD = 0;
      "
      max2 = 0;
      
      self.RangoDatos.each do |k,v|
        if v > max2 
          max2 = v
        end
        cam = k.split('-')
        if cam.count == 1 
          cam << cam[0]
        end
        lista2 += "listaRD[#{v}] = '#{cam[0]}';
        listaRD2[#{v}] = '#{cam[1]}';
        "
      end
      
      lista2 += "
      maxRD = #{max2};
      "
      return lista2
    end 

    
    def make
      puts "hecho bazarcms empresas datos"
    end
    
  end
end