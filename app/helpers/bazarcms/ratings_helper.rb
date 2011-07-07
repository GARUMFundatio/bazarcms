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