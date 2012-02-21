module Bazarcms
  
  unloadable
  
  class Empresasimagen < ActiveRecord::Base
    set_table_name "empresasimagenes"
        
    has_attached_file :imagen, :styles => {
          :thumb=> "100x50>",
          :small  => "150x150>",
          :s223 => "223x223",
          :s60 => "60x60" },
          :path => ":rails_root/public/:class/:attachment/:id/:style_:basename.:extension",
          :url => "/:class/:attachment/:id/:style_:basename.:extension",
          :default_url => "/images/sinlogo.png"
    
 
  end
  
end