Rails.application.routes.draw do |map|

  montar_en = Bazarcms::Engine.config.montar_en

  match "/bazarcms" => 'bazarcms/empresas#index'

  map.resources :empresas, :only => [ :index, :show ],
                          :controller => "bazarcms/empresas",
                          :path_prefix => "/bazarcms/",
                          :name_prefix => "bazarcms_"
 
  map.resources :empresasdatos, :only => [ :index, :show ],
                        :controller => "bazarcms/empresasdatos",
                        :path_prefix => "/bazarcms/",
                        :name_prefix => "bazarcms_"

end
