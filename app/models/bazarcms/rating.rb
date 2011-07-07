module Bazarcms
  
  unloadable

  class Rating < ActiveRecord::Base
    set_table_name "ratings"
    
  def calculo (bazar, empresa)
    
    if (bazar.to_i == BZ_param('BazarId').to_i)
    
      total_rating_global = 0 
      total_global = 0
      
      total_rating_cliente = 0
      total_val_cliente = 0 
      
      total_rating_proveedor = 0
      total_val_proveedor = 0 
      
      rats = Rating.where("(ori_bazar_id = ? and ori_empresa_id = ?) or (des_bazar_id = ? and des_empresa_id = ?)", bazar, empresa, bazar, empresa)
    
      for rat in rats 
        
        
      end 
      
    end 
    
  end

end