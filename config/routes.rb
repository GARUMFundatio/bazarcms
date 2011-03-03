
Bazar::Application.routes.draw do
  
  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :empresas
  end

  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :empresasdatos
  end

  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :empresasconsultas
  end

  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :empresasresultados
  end

  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    # resources :ubicaciones
    resources :ubicaciones do
      get :autocomplete_ciudad_descripcion, :on => :collection
    end  
  end
 
  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    # resources :perfiles
    resources :perfiles do
      get :autocomplete_perfil_descripcion, :on => :collection
    end
  end
 
  match "/bazarcms/datos" => "bazarcms/empresasdatos#index"
  match "/bazarcms/dashboard" => "bazarcms/empresas#dashboard"
  match "/bazarcms/buscadorempresas" => "bazarcms/empresas#buscador"
  match "/bazarcms/buscaempresas" => "bazarcms/empresas#busca"
  match "/bazarcms/resultadoempresas" => "bazarcms/empresas#resultado"
  match "/bazarcms/enviabusqueda" => "bazarcms/empresas#enviabusqueda"
  match "/bazarcms/borrarconsultas" => "bazarcms/empresasconsultas#borrartodas"
  match "/bazarcms/estadoconsulta/:id" => "bazarcms/empresasconsultas#estado", :constrants => { :id => /\d+/ }
  match "/bazarcms/estadobusqueda" => "bazarcms/empresas#estadobusqueda"
  match "/bazarcms/directorio" => "bazarcms/empresas#list"
  match "/bazarcms/empresas/show2/:id" => "bazarcms/empresas#show2", :constrants => { :id => /\d+/ }
  
  
    
end