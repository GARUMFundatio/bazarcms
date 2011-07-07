module Bazarcms
  
  unloadable

  class Rating < ActiveRecord::Base
    set_table_name "ratings"
    
    def calculo (bazar, empresa)
        
      total_rating_global = 0 
      total_global = 0
    
      total_rating_cliente = 0
      total_val_cliente = 0 
    
      total_rating_proveedor = 0
      total_val_proveedor = 0 
    
      rats = Rating.where("(ori_bazar_id = ? and ori_empresa_id = ?) or (des_bazar_id = ? and des_empresa_id = ?)", bazar, empresa, bazar, empresa)

      hay = false 
  
      for rat in rats 
      
        if rat.ori_bazar_id = bazar and rat.ori_empresa_id = empresa           
          ori = true 
        end 
      

        if rat.role == 'C'

          total_val_cliente += 1  
        
        end

        if rat.role == 'P'

          total_val_proveedor += 1 
        
        end


        #actualizamos los datos de la empresa 
      
        empresa = Empresa.find_by_id(empresa)

        empresa.rating_total_cliente = total_val_cliente
        empresa.rating_total_proveedor = total_val_proveedor

        empresa.save
      
      end 
    
    end 

  end

end