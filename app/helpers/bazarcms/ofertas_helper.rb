module Bazarcms
  module OfertasHelper
  

    def helper_oferta_edit(bazar, empresa, oferta)

      if (bazar.to_i != BZ_param("BazarId").to_i)
        return ""
      end 
      
      if (empresa != current_user.id)
        return ""
      end 
      
      str = "<a href='#{url}' rel='nofollow'>"       
      str += "</a>"

      str 

    end
 
  end
end