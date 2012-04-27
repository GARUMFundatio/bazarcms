xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title BZ_param("Titular")+": Ofertas de la red de Bazares de la Garum Fundatio"
    xml.description BZ_param("Subtitular")
    xml.link Cluster.find(BZ_param("BazarId")).url

    for oferta in @ofertas
      xml.item do
        xml.title oferta.info
        xml.description "Más Información de esta oferta/demanda:\n\n<a href='#{Cluster.find(BZ_param("BazarId")).url}/home/fichaoferta/#{oferta.cluster_id}/"+oferta.oferta_id.to_s+"'>"+oferta.info+'</a>'
        xml.pubDate Date.today.to_s(:rfc822)
        xml.link Cluster.find(BZ_param("BazarId")).url+"/home/fichaoferta/#{oferta.cluster_id}/#{oferta.oferta_id}"
        xml.guid Cluster.find(BZ_param("BazarId")).url+"/home/fichaoferta/#{oferta.cluster_id}/#{oferta.oferta_id}"
      end
    end
  end
end