module Bazarcms
  class Engine < Rails::Engine

    config.montar_en = '/bazarcms'
    config.bazarcms_factory_name = 'Bazarcms'
    puts "bazarcms:: inicializo el engine <---------------------"
    
    ActiveSupport::Inflector.inflections do |inflect|
      puts "inflectors de la gema bazarcms"
      inflect.irregular 'interes', 'intereses'
      inflect.irregular 'ubicacion', 'ubicaciones'
      inflect.irregular 'empresa', 'empresas'
      inflect.irregular 'empresasdato', 'empresasdatos'
      inflect.irregular 'empresasconsulta', 'empresasconsultas'
      inflect.irregular 'empresasresultado', 'empresasresultados'
      inflect.irregular 'empresasperfil', 'empresasperfiles'
      inflect.irregular 'empresasimagen', 'empresasiamgenes'
      inflect.irregular 'perfil', 'perfiles'
      inflect.irregular 'oferta', 'ofertas'
      inflect.irregular 'ofertasconsulta', 'ofertasconsultas'
      inflect.irregular 'ofertasresultado', 'ofertasresultados'
      inflect.irregular 'ofertasperfil', 'ofertasperfiles'
      inflect.irregular 'ofertaspais', 'ofertaspaises'
      inflect.irregular 'ofertasfavorito', 'ofertasfovoritos'
      inflect.irregular 'ofertasimagen', 'ofertasimagenes'
      inflect.irregular 'rating', 'ratings'
      
    end
     
    # cargamos los locales de bazarcms 
    
    path=File.dirname(__FILE__)
    I18n.load_path += Dir[ File.join(path, '../locales/bazarcms', '*.{rb,yml}') ]

#    puts "-----> Cargamos los locales de: #{path}"
    
#    puts "-----> Cargamos los locales de: #{I18n.load_path.inspect}"
    
     
#     Bazarcms::Application.config.middleware.use ::ExceptionNotifier,
#        :email_prefix => "[Bazar Garum] ",
#        :sender_address => %{"Notifier" <juantomas@geofun.es>},
#        :exception_recipients => %w{juantomas.garcia@gmail.com}
     
  end
end
