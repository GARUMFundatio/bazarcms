
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
  match "/bazarcms/buscadorempresas" => "bazarcms/empresas#buscador"
  match "/bazarcms/buscaempresas" => "bazarcms/empresas#busca"
  match "/bazarcms/resultadoempresas" => "bazarcms/empresas#resultado"
  
end