#lib/authr/engine.rb
require "bazar_cms"
require "rails"

module Bazar_cms
  class Engine < Rails::Engine
    engine_name :bazar_cms
 
    # Configuracion por defecto 
    config.bazarcms_factory_name = "bazar cms por defecto"
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
