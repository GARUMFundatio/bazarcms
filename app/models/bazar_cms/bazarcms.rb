module Bazar_cms
  class BazarCMS < ActiveRecord::Base
    set_table_name "bazar_cms"

    def make
      puts "hecho bazar_cms"
    end
    
  end
end