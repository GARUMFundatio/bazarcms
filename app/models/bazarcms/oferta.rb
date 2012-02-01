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

      # default values 
      
      tipo = 'O'
      q = "*"
      user = 1
      bazar = 1
      filtro = "all"
      orden = "fecha desc"
      limit = 180
      
      # processing the params
      
      p[0].each do |k,v|
        puts "#{k} ---> #{v}"
        
        case k 
        when :tipo
          tipo = v
          puts "tipo ahora vale: #{tipo}"
        when :q
          q = v 
          puts "q ahora vale: #{q}"
        when :user
          user = v 
          puts "user ahora vale: #{user}"
        when :bazar
          bazar = v 
          puts "bazar ahora vale: #{bazar}"
        when :filtro
          filtro = v
          puts "filtro ahora vale: #{filtro}"          
        when :orden
          orden = v
          puts "orden ahora vale: #{orden}"          
        when :limit
          limit = v
          puts "orden ahora vale: #{limit}"          
        end 
        
      end
      
      q = "*" if q == ""

      logger.debug "tipo  : #{tipo}"
      logger.debug "q     : #{q}"
      logger.debug "user  : #{user}"
      logger.debug "bazar : #{bazar}"
      logger.debug "filtro: #{filtro}"
      logger.debug "orden : #{orden}"
      logger.debug "limit : #{limit}"

      # starting the searching

      # we register the search 
      
      @clusters = Cluster.where("activo = 'S'")
      micluster = bazar.to_i
      
      @consulta = Ofertasconsulta.new
      @consulta.empresa_id = user 

      logger.debug "------> (#{q}) unscaped (#{CGI.unescape(q)})"

      @consulta.desc = CGI.unescape(q)
      @consulta.total_consultas = @clusters.count()
      @consulta.total_respuestas = 0
      @consulta.total_resultados = 0
      @consulta.fecha_inicio = DateTime::now
      @consulta.fecha_fin = nil

      # TODO: deberíamos meter todo el query para luego interpretarlo

      @consulta.sql = q
      @consulta.save

      if (q == "*")
        resultados = Bazarcms::Oferta.where("tipo = ?", tipo).order(orden).limit(limit)
      else 
        resultados = Bazarcms::Oferta.find_with_ferret(q, :limit => :all)        
      end

      conta2 = 0
      for resu in resultados 
           
        entra = 0
        total = 0

        # TODO: new filters here

        if (entra == total)
          @res = Ofertasresultado.new(); 
          @res.ofertasconsulta_id = @consulta.id
          @res.cluster_id = micluster
          @res.empresa_id = resu.empresa_id
          @res.oferta_id = resu.id
          @res.tipo = resu.tipo
          @res.nombre_empresa = "poner nombre bien"
                     
          @res.orden = resu.fecha
          @res.enlace = "poner el enlace bien" # resu.url
          @res.info = "#{resu.titulo}"
          @res.save
          conta2 += 1
        end 
         
      end 
      
      @consulta.total_resultados = @consulta.total_resultados + conta2;
      @consulta.save


      # we return the results of the search 
      
      return resultados
      
    end 
    
  end

end