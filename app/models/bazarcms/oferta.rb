module Bazarcms
  
  unloadable


  # TODO: incluir sectores y paises 
  
  class Oferta < ActiveRecord::Base

    set_table_name "ofertas"

    # TODO establecer bien las relaciones
    
    belongs_to :empresa
  
    has_many :ofertasconsultas
  
    acts_as_ferret :fields => [ :titulo, :texto ]
    
    has_friendly_id :titulo, :use_slug => true, :approximate_ascii => true
    
    def self.mostrada(bazar_id, oferta_id)

      oferta = Bazarcms::Oferta.find_by_bazar_id_and_id(bazar_id, oferta_id) 
      if (!oferta.nil?)
        
        oferta.vistas += 1
        oferta.save

        # TODO: comprobar si hace falta actualizar en remoto si oferta es de otro bazar    
        
      end
      
    end 
  
    def self.busca(*p)
      tipo = 'O'
      q = "*"
      p[0].each do |k,v|
        puts "#{k} ---> #{v}"
        
        case k 
        when :tipo
          tipo = v
          puts "tipo ahora vale: #{tipo}"
        when :q
          q = v 
          puts "q ahora vale: #{q}"
        end 
        
      end
      
      q = "*" if q == ""

      puts "tipo  : #{tipo}"
      puts "q     : #{q}"

      if (q == "*")
        resultados = Bazarcms::Oferta.where("tipo = 'O'")
      else 
        resultados = Bazarcms::Oferta.find_with_ferret(q, :limit => :all)        
      end

      return resultados
      
    end 
    
  end

end