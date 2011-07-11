module Bazarcms
  module RatingsHelper
  
    def helper_for_widgets_view
      "esta salida viene del BazarCMSHelper"
    end

    def helper_rating_show(valor, url)
      
      val = "#{valor}".split('.')[0]
      str = "<div><a href='#{url}'>" 
      
      for ii in ['1', '2', '3', '4', '5'] 
      
        if (ii > val) 
          str += "<img src='/images/addfav.png'>"
        else 
          str += "<img src='/images/rating.png'>"
        end 
        
      end 
      
      str += "</a></div>"
      str 
    end

    def helper_rating_show2(bazar, empresa)
      
      if (bazar == BZ_param("BazarId"))
        
        empresa = Bazarcms::Empresa.find_by_id(empresa)
        
        valor = empresa.rating
        nombre = empresa.nombre
        
        url = "/bazarcms/ratings/new?bazar_id=#{bazar}&empresa_id=#{empresa}&empresa_nombre=#{nombre}"
        
      else 
        
        valor = 0
        url = ""
      end
      
      val = "#{valor}".split('.')[0]
      str = "<div><a href='#{url}'>" 
      
      for ii in ['1', '2', '3', '4', '5'] 
      
        if (ii > val) 
          str += "<img src='/images/addfav.png'>"
        else 
          str += "<img src='/images/rating.png'>"
        end 
        
      end 
      
      str += "</a></div>"
      str 
    end




    def helper_rating_calc(valor)
      
      val = "#{valor}".split('.')[0]
      str = "<div>" 
      
      for ii in ['1', '2', '3', '4', '5'] 
      
        if (ii > val) 
          str += "<img src='/images/addfav.png'>"
        else 
          str += "<img src='/images/rating.png'>"
        end 
        
      end 
      
      str += "</div>"
      str 
    end

    
  end
end