#lib/authr/engine.rb
require "bazarcms"
require "rails"
require 'action_controller'
require 'application_helper'


module Bazarcms
  class Engine < Rails::Engine
   
    # Configuracion por defecto 
    config.bazarcms_factory_name = "Bazarcms"
    config.montar_en = '/'
    
    # Ejecuto los task que tengamos
    rake_tasks do
      load File.join(File.dirname(__FILE__), 'rails/railties/tasks.rake')
    end
    
    # Check the gem config
    initializer "check config" do |app|

      
      # make sure mount_at ends with trailing slash
      config.montar_en += '/'  unless config.montar_en.last == '/'
    end
    
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end 
  
  end
end
