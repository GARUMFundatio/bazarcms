module Bazarcms
  
  unloadable

  # TODO: incluir sectores y paises 
  
  class Oferta < ActiveRecord::Base

    set_table_name "ofertas"

    # TODO establecer bien las relaciones
    
    belongs_to :empresa
  
    has_many :ofertasconsultas
  
    acts_as_taggable
    acts_as_taggable_on :palabrasclave
  
    acts_as_ferret :fields => [ :titulo, :texto, :palabrasclave ]
    
    has_friendly_id :titulo, :use_slug => true, :approximate_ascii => true
    
    
    def self.mostrada(bazar_id, oferta_id)

      oferta = Bazarcms::Oferta.find_by_bazar_id_and_id(bazar_id, oferta_id) 
      if (!oferta.nil?)
        
        oferta.vistas += 1
        oferta.save

        # TODO: comprobar si hace falta actualizar en remoto si oferta es de otro bazar    
        
      end
      
    end 
  
    def self.Ambitos
        {
         "Mi Bazar" => "0", 
         "Nacional"  => "1",
         "Internacional" => "2"       
         }
    end
    
    def self.Ambitostexto(ind)
      self.Ambitos.each do |k,v| 
        if v.to_i == ind.to_i
          return k
        end
      end
      return "No definido"
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

      logger.debug "------> (#{q}) "

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
          @res.nombre_empresa = "#{resu.texto}"
                     
          @res.orden = resu.fecha
          @res.enlace = "#{resu.fecha_hasta}"
          @res.info = "#{resu.titulo}"
          @res.save
          
          # increment the counter of views

          resu.vistas += 1 
          resu.save
          
          conta2 += 1
        end 
         
      end 
      
      @consulta.total_resultados = @consulta.total_resultados + conta2;
      @consulta.save

      # looking for another bazares

      conta = conta2 = 0 
      
      hydra = Typhoeus::Hydra.new

      logger.debug "lanzo las peticiones "+DateTime.now.to_s

      for cluster in @clusters

        if micluster != cluster.id 

          # uri = "#{cluster.url}/bazarcms/buscaofertas?q="+CGI.escape(q)+"&qtipo="+CGI.escape(tipo)+"&bid=#{@consulta.id}&cid=#{micluster}"
          # /bazarcms/buscaofertas?q=bazar&qe=0+10&qv=0+10&qc=0+10&qr=0+10&pofertan=&pdemandan=&ppaises=&qtipo=D&bid=1&cid=8
          
          uri = "#{cluster.url}/bazarcms/buscaofertas?q="+CGI.escape(q)+"&qe="+CGI.escape("0")+"&qv="+CGI.escape("0")+"&qc="+CGI.escape("0 10")+"&qr="+CGI.escape("0 10")+"&pofertan="+CGI.escape("")+"&pdemandan="+CGI.escape("")+"&ppaises="+CGI.escape("")+"&qtipo="+CGI.escape(tipo)+"&bid=#{@consulta.id}&cid=#{micluster}"
          logger.debug "Enviando Petición a ------------> #{uri}"

          r = Typhoeus::Request.new(uri, :timeout => 5000)
          r.on_complete do |response|
            logger.debug "-------------> "+response.inspect
            case response.curl_return_code
            when 0
              conta += 1
              conta2 = 0

              begin
                ofertas = JSON.parse(response.body)

                logger.debug "#{ofertas.inspect} <-----------"
                cluster_id = 0 
                ofertas.each{ |key|
                  logger.debug("#{key.inspect}")
                  if !key['cluster_id'].nil?
                    logger.debug "viene un cluster id "+key.inspect
                    cluster_id = key['cluster_id']
                  end
                  if !key['oferta'].nil?
                    logger.debug("#{key['oferta'].inspect} <------ datos")

                    resu = Bazarcms::Ofertasresultado.new()    
                    resu.ofertasconsulta_id = @consulta.id
                    resu.cluster_id = cluster_id
                    resu.oferta_id = key['oferta']['id']
                    resu.tipo =  key['oferta']['tipo']
                    resu.empresa_id = key['oferta']['empresa_id'] 
                    resu.nombre_empresa = key['oferta']['texto']
                    resu.enlace = key['oferta']['fecha_hasta'] # key['oferta']['url']
                    resu.orden = key['oferta']['fecha'] # .strftime('%Y%m%d%H%M')
                    resu.info = key['oferta']['titulo']
                    resu.save
                    conta2 += 1
                  end
                  }

                @consulta.total_respuestas = @consulta.total_respuestas + 1;
                @consulta.total_resultados = @consulta.total_resultados + conta2;
                @consulta.save
              rescue 
                logger.debug "El JSON: venía mal formado #{response.body}"

              end 
            else
              logger.debug "ERROR en la petición ---------->"+response.inspect
            end

          end

          hydra.queue r        

        end

      end 

      hydra.run

      logger.debug "servidas "+DateTime.now.to_s

      @consulta.total_consultas = conta;
      @consulta.fecha_fin = DateTime::now

      @consulta.save

      @consultasresultados = Bazarcms::Ofertasresultado.where("ofertasconsulta_id = ?", @consulta.id).order("orden desc")
      
      # we return the results of the search 
      
      return resultados, @consultasresultados
      
    end 
    
  end

end