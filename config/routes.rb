Rails.application.routes.draw do |map|

  montar_en = Cheese::Engine.config.montar_en

  match montar_en => 'bazar_cms/bazarcms#index'

  map.resources :bazarcms, :only => [ :index, :show ],
                          :controller => "bazar_cms/bazarcms",
                          :path_prefix => montar_en,
                          :name_prefix => "bazar_cms_"

end
