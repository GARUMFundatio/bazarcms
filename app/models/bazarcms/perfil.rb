module Bazarcms
  
  unloadable

  class Perfil < ActiveRecord::Base

    set_table_name "perfiles"

    belongs_to :empresa
  
  end

end