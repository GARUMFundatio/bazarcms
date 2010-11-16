Rails.application.routes.draw do |map|

  montar_en = Bazarcms::Engine.config.montar_en

  # match "/bazarcms" => 'bazarcms/empresas#index'

  map.resources :empresas, #:only => [ :index, :show, :edit, :update ],
                          :controller => "bazarcms/empresas",
                          :path_prefix => "/bazarcms/",
                          :name_prefix => "bazarcms_"
 
  map.resources :empresasdatos, :only => [ :index, :show, :edit ],
                        :controller => "bazarcms/empresasdatos",
                        :path_prefix => "/bazarcmsdatos/",
                        :name_prefix => "bazarcmsdatos_"

end
