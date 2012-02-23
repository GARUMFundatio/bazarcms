module Bazarcms
  
  unloadable
  
  class Empresa < ActiveRecord::Base
    set_table_name "empresas"
    has_many :ubicaciones
    has_many :empresasconsultas
    has_many :empresasperfiles
    
    acts_as_taggable
    acts_as_taggable_on :actividades, :intereses
    
    has_attached_file :logo, :styles => {
          :thumb=> "100x50>",
          :small  => "150x150>",
          :s223 => "223x223",
          :s60 => "60x60" },
          :path => ":rails_root/public/:class/:attachment/:id/:style_:basename.:extension",
          :url => "/:class/:attachment/:id/:style_:basename.:extension",
          :default_url => "/images/sinlogo.png"
    
    
    # TODO deberíamos incluir nombre de la ciudad y el pais en la indexación
    
    
    scope :ultimascreadas, order("empresas.created_at DESC").limit(5)
    scope :ultimasactualizadas, order("empresas.updated_at DESC").limit(5)
        
    acts_as_ferret :fields => [ :nombre, :desc, :actividades, :intereses, :sitios, :sectores ]

    has_friendly_id :nombre, :use_slug => true, :approximate_ascii => true
    
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
    
    def self.Ambitos
        {
         "Local" => "0", 
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

    def sectores
      tmp = []
      for per in empresasperfiles

        tmp << per.codigo
        
        sec = Bazarcms::Perfil.find_by_codigo(per.codigo)
        tmp << sec.desc
        tmp << sec.ayuda

      end
      logger.debug "sectores añadidos a la busqueda: "+tmp.inspect
      return tmp
    end
        
    
    def interesantes
      puts "Empresas interesantes para: #{self.id} #{self.nombre}"
      
      missectores = Bazarcms::Empresasperfil.select("distinct codigo").where("empresa_id = ?", self.id).order("codigo")

      sectores = []

      for sector in missectores 
        sectores << sector.codigo
      end

      puts sectores.inspect
      
      res = {}
      
      empresas = Bazarcms::Empresasperfil.select("distinct empresa_id").where("empresa_id <> ? and codigo in (?)", self.id, sectores).order("empresa_id")
      puts empresas.inspect 
      
      if empresas.count <= 0
        
        empresas = Bazarcms::Empresa.select("id").where("id <> ? ", self.id).order("id desc").limit(18)
        puts "no habia empresas para recomendar"
        puts empresas.inspect 

        for emp in empresas
          if res[emp.id.to_s].nil? 
            res[emp.id.to_s] = 1
          else 
            puts "ya estaba #{emp.empresa_id}"
          end
        end    

      else 
      
        for emp in empresas
          if res[emp.empresa_id.to_s].nil? 
            res[emp.empresa_id.to_s] = 1
          else 
            puts "ya estaba #{emp.empresa_id}"
          end
        end    

      end
      
      return res

    end
    def self.busca(*p)

      # default values 

      tipo = 'O'
      q = "*"
      user = 1
      bazar = 1
      filtro = "all"
      orden = "rating desc"
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

      @consulta = Empresasconsulta.new
      @consulta.empresa_id = user 

      logger.debug "------> (#{q}) unscaped (#{CGI.unescape(q)})"

      @consulta.desc = q
      @consulta.total_consultas = @clusters.count()
      @consulta.total_respuestas = 0
      @consulta.total_resultados = 0
      @consulta.fecha_inicio = DateTime::now
      @consulta.fecha_fin = nil
      @consulta.sql = q
      @consulta.save

      conta = 0
      micluster = bazar
      logger.debug "ID de mi cluster #{micluster} <------"



      if (q == "*")
        resultados = Bazarcms::Oferta.where("tipo = ?", tipo).order(orden).limit(limit)
      else 
        resultados = Bazarcms::Oferta.find_with_ferret(q, :limit => :all)        
      end

      if (q == '*')
        resultados = Empresa.where('1 =1').order(orden).limit(limit)
      else 
        resultados = Empresa.find_with_ferret(q, :limit => :all)        
      end

      logger.debug "resu: (#{resultados.inspect}) <-------"

      conta2 = 0
      for resu in resultados 

        entra = 0
        total = 0

        # TODO: new filters here

        if (entra == total)
          @res = Empresasresultado.new(); 
          @res.empresasconsulta_id = @consulta.id
          @res.cluster_id = micluster
          @res.empresa_id = resu.id 

          num = resu.rating * 1000 + ( resu.rating_total_cliente + resu.rating_total_proveedor)

          @res.orden = "#{num}"
          @res.enlace = resu.url
          @res.info = "#{resu.nombre}"
          @res.save
          # increment the counter of views

          resu.total_mostradas += 1 
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
          #uri = "#{cluster.url}/bazarcms/buscaempresas?q="+CGI.escape(params[:q])+"&qe="+CGI.escape(params[:qe])+"&qv="+CGI.escape(params[:qv])+"&qc="+CGI.escape(params[:qc])+"&qr="+CGI.escape(params[:qr])+"&pofertan="+CGI.escape(params[:pofertan])+"&pdemandan="+CGI.escape(params[:pdemandan])+"&ppaises="+CGI.escape(params[:ppaises])+"&bid=#{@consulta.id}&cid=#{micluster}"

          uri = "#{cluster.url}/bazarcms/buscaempresas?q="+CGI.escape(q)+"&qe="+CGI.escape("0")+"&qv="+CGI.escape("0")+"&qc="+CGI.escape("0 10")+"&qr="+CGI.escape("0 10")+"&pofertan="+CGI.escape("")+"&pdemandan="+CGI.escape("")+"&ppaises="+CGI.escape("")+"&qtipo="+CGI.escape(tipo)+"&bid=#{@consulta.id}&cid=#{micluster}"
          logger.debug "Enviando Petición a ------------> #{uri}"

          r = Typhoeus::Request.new(uri, :timeout => 5000)
          r.on_complete do |response|
            logger.debug "-------------> "+response.inspect
            case response.curl_return_code
            when 0
              conta += 1
              conta2 = 0

              begin
              empresas = JSON.parse(response.body)

              logger.debug "#{empresas.inspect} <-----------"
              cluster_id = 0 
              empresas.each{ |key|
                logger.debug("#{key.inspect}")
                if !key['cluster_id'].nil?
                  logger.debug "viene un cluster id "+key.inspect
                  cluster_id = key['cluster_id']
                end
                if !key['empresa'].nil?
                  logger.debug("#{key['empresa'].inspect} <------ datos")
                  resu = Bazarcms::Empresasresultado.new()
                  resu.empresasconsulta_id = @consulta.id
                  resu.cluster_id = cluster_id
                  resu.empresa_id = key['empresa']['id'] 
                  resu.enlace = key['empresa']['url']
                  num = key['empresa']['rating'].to_i * 1000 + ( key['empresa']['rating_total_cliente'].to_i + key['empresa']['rating_total_proveedor'].to_i)
                  resu.orden = "#{num}"
                  resu.info = key['empresa']['nombre']
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

      @empresasresultados = Bazarcms::Empresasresultado.where("empresasconsulta_id = ?", @consulta.id).order("orden desc")

      # we return the results of the search 

      return resultados, @empresasresultados

    end 
    
  end
  
end