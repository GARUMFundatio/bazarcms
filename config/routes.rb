
# Rails.application.routes.draw do |map|

#  match "/bazarcms/datos" => "bazarcms/empresasdatos#index"
#  match "/bazarcms/dashboard" => "bazarcms/empresas#dashboard"
  
#  map.resources :ubicaciones, 
#                          :controller => "bazarcms/ubicaciones",
#                          :path_prefix => "/bazarcms/",
#                          :name_prefix => "bazarcms_"
 
#  map.resources :empresas, #:only => [ :index, :show, :edit, :update ],
#                          :controller => "bazarcms/empresas",
#                          :path_prefix => "/bazarcms/",
#                          :name_prefix => "bazarcms_"
 
#  map.resources :empresasdatos, #:only => [ :index, :show, :edit ],
#                        :controller => "bazarcms/empresasdatos",
#                        :path_prefix => "/bazarcms/",
#                        :name_prefix => "bazarcms_"

# end

Bazar::Application.routes.draw do
  scope(:path => 'bazarcms', :module => 'bazarcms', :name_path => 'bazarcms', :name_prefix => 'bazarcms' ) do
    resources :empresas

  end

  scope(:path => 'bazarcms', :module => 'bazarcms', :name_prefix => 'bazarcms' ) do
    resources :empresasdatos
  end

  scope(:path => 'bazarcms', :module => 'bazarcms', :name_prefix => 'bazarcms' ) do
    # resources :ubicaciones
    resources :ubicaciones do
      get :autocomplete_ciudad_descripcion, :on => :collection
    end
  
  end
 
  
  match "/bazarcms/datos" => "bazarcms/empresasdatos#index"
  match "/bazarcms/dashboard" => "bazarcms/empresas#dashboard"
  
end