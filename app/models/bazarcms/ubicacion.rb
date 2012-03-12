module Bazarcms
  
  unloadable

  class Ubicacion < ActiveRecord::Base
    set_table_name "ubicaciones"
    
    belongs_to :empresa
    belongs_to :ciudad
  
    def self.distancia(desde, hasta)
  
      ori = Ciudad.find_by_geocode(desde)
      des = Ciudad.find_by_geocode(hasta)
      puts "Calculando la distancia entre #{ori.descripcion}:#{ori.geocode} y #{des.descripcion}:#{des.geocode}"
      puts "#{ori.descripcion} = #{ori.longitud} #{ori.latitud}"
      puts "#{des.descripcion} = #{des.longitud} #{des.latitud}"

      puts "km #{calculo(ori.latitud, ori.longitud, des.latitud, des.longitud)}"
      return calculo(ori.latitud, ori.longitud, des.latitud, des.longitud)
    end
    
    def self.calculo(lat1, lon1, lat2, lon2)
      
      rad_per_deg = 0.017453293

      rkm = 6371              

      
      dlon = lon2 - lon1
      dlat = lat2 - lat1

      dlon_rad = dlon * rad_per_deg 
      dlat_rad = dlat * rad_per_deg

      lat1_rad = lat1 * rad_per_deg
      lon1_rad = lon1 * rad_per_deg

      lat2_rad = lat2 * rad_per_deg
      lon2_rad = lon2 * rad_per_deg

      
      a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
      c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))

      dKm = rkm * c             # delta in kilometers

      # @distances["mi"] = dMi
      # @distances["km"] = dKm
      # @distances["ft"] = dFeet
      # @distances["m"] = dMeters

      return dKm
      
    end
  
  end

end