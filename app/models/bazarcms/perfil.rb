module Bazarcms
  
  unloadable

  class Perfil < ActiveRecord::Base

    set_table_name "perfiles"
    has_friendly_id :desc, :use_slug => true, :approximate_ascii => true
    
    belongs_to :empresa
  
  end

end