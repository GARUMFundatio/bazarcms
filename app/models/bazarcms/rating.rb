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
    
      puts "Calculando la ficha de rating para bazar #{bazar} empresa #{empresa} "
    
      rats = Rating.where(" des_bazar_id = ? and des_empresa_id = ? ", bazar, empresa)
      
      hay = false 
      
      if rats == []
        logger.debug "Nadie le ha evaluado todavía"
        return
      end 
      
      for rat in rats 
      
        # primero determinamos si la empresa es la que ha originado el rating 
        puts "--->> bazar #{rat.ori_bazar_id} empresa #{rat.ori_empresa_id} #{rat.ori_empresa_nombre} --->> bazar #{rat.des_bazar_id} empresa #{rat.des_empresa_id} #{rat.des_empresa_nombre} (#{rat.role})"
        
        mieval = Bazarcms::Rating.where("ori_bazar_id = ? and ori_empresa_id = ? and des_bazar_id = ? and des_empresa_id = ?",
                                        bazar, empresa, rat.ori_bazar_id, rat.ori_empresa_id).limit(1)
        
        # si yo he evaluado esta empresa podemos calcular el ratio, si no pasamos al siguiente rating                                  
        if mieval == [] 
          logger.debug "Esta empresa no ha evaludado a #{rat.ori_bazar_id} -> #{rat.ori_empresa_id}"
          logger.debug "Hay que avisarla y penalizarla"
          next
        else 
          logger.debug "Tenemos doble rating, calculamos"
        end 
                
        totrc = totrp = 0
        totc = totp = 0

        # hay que añadir los roles cuando volvamos al modo no pajaru
        
        if (rat.ori_proveedor_expectativas > 0)  
          totrp += rat.ori_proveedor_expectativas
          totp += 1
        end
        if (rat.ori_proveedor_plazos > 0)  
          totrp += rat.ori_proveedor_plazos
          totp += 1
        end
        if (rat.ori_proveedor_comunicacion > 0)  
          totrp += rat.ori_proveedor_comunicacion
          totp += 1
        end 
        if (rat.ori_cliente_plazos > 0)  
           totrc += rat.ori_cliente_plazos
           totc += 1
        end
        
        if (rat.ori_cliente_comunicacion > 0)  
          totrc += rat.ori_cliente_comunicacion
          totc += 1
        end

        if (totc > 0)
          total_rating_cliente += (totrc/totc)
          total_val_cliente += 1
        end  

        if (totp > 0)
          total_rating_proveedor += (totrp/totp)
          total_val_proveedor += 1
        end  

      end 

      #actualizamos los datos de la empresa 
    
      empresa = Empresa.find_by_id(empresa)

      if total_val_cliente > 0
        empresa.rating_cliente = total_rating_cliente/total_val_cliente
      else 
        empresa.rating_cliente = 0
      end

      if total_val_proveedor > 0
        empresa.rating_proveedor = total_rating_proveedor/total_val_proveedor
      else 
        empresa.rating_proveedor = 0
      end

      if (total_val_cliente > 0 || total_val_proveedor > 0)
        empresa.rating = (total_rating_cliente + total_rating_proveedor) / (total_val_cliente + total_val_proveedor)
      else 
        empresa.rating = 0        
      end 
      
      empresa.rating_total_cliente = total_val_cliente
      empresa.rating_total_proveedor = total_val_proveedor
      empresa.save
    
    end 

  end

end