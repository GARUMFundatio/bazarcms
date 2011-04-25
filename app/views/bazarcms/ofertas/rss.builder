xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title BZ_param("Titular")+": Ofertas del Bazar Garum"
    xml.description BZ_param("Subtitular")
    xml.link Cluster.find(BZ_param("BazarId")).url

    for oferta in @ofertas
      xml.item do
        xml.title oferta.titulo
        xml.description oferta.texto+"<br/><br/>"+"Más Información de esta oferta/demanda:\n\n<a href='/bazarcms/ofertas/show2/"+oferta.friendly_id+"'>"+oferta.titulo+'</a>'
        xml.pubDate actividad.fecha.to_s(:rfc822)
        xml.link Cluster.find(BZ_param("BazarId")).url+"/bazarcms/ofertas/#{actividad.friendly_id}"
        xml.guid Cluster.find(BZ_param("BazarId")).url+"/bazarcms/ofertas/#{actividad.friendly_id}"
      end
    end
  end
end