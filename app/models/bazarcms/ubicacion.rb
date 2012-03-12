module Bazarcms
  
  unloadable

  class Ubicacion < ActiveRecord::Base
    set_table_name "ubicaciones"
    
    belongs_to :empresa
    belongs_to :ciudad
  
  def self.distancia(desde, hasta)
  
    ori = Bazarcms::Ciudad.where("geocode = ?", desde)
    des = Bazarcms::Ciudad.where("geocode = ?", hasta)
    puts "Calculando la distancia entre #{ori.descripcion}:#{ori.geocode} y #{des.descripcion}:#{des.geocode}"
    puts "#{ori.descripcion} = #{ori.longitud} #{ori.latitud}"
    puts "#{des.descripcion} = #{des.longitud} #{des.latitud}"

  end

end