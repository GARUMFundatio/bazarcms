module Bazarcms
  
  unloadable
  
  class Ofertasimagen < ActiveRecord::Base
    set_table_name "ofertasimagenes"
        
    has_attached_file :imagen, :styles => {
          :thumb=> "100x50>",
          :small  => "150x150>",
          :s223 => "223x223",
          :s60 => "60x60",
          :c223 => "223x223^",
          :c60 => "60x60^"
          },
          :convert_options => {
            :c223 => " -gravity center -extent 223x223^",
            :c60 => " -gravity center -extent 60x60^"
          },
          :path => ":rails_root/public/:class/:attachment/:id/:style_:basename.:extension",
          :url => "/:class/:attachment/:id/:style_:basename.:extension",
          :default_url => "/images/sinlogo.png"
    
    validates_attachment_content_type :imagen, :content_type=>['image/jpeg', 'image/png', 'image/gif']
          
  end
  
end