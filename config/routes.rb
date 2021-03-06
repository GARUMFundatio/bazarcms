
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
    resources :empresasperfiles
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
 
  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :ofertas
  end
  
  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :ofertasconsultas
  end
  
  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :ofertasconsultasresultados
  end
  
  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :ofertasperfiles
  end

  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :ofertaspaises
  end
  
  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :ofertasfavoritos
  end
  
  scope(:path => 'bazarcms', :module => 'bazarcms', :as => 'bazarcms' ) do
    resources :ratings
  end
  
 
  match "/bazarcms/datos" => "bazarcms/empresasdatos#index"
  match "/bazarcms/dashboard" => "bazarcms/empresas#dashboard"
  match "/bazarcms/buscadorempresas" => "bazarcms/empresas#buscador"
  match "/bazarcms/buscaempresas" => "bazarcms/empresas#busca"
  match "/bazarcms/resultadoempresas" => "bazarcms/empresas#resultado"
  match "/bazarcms/enviabusqueda" => "bazarcms/empresas#enviabusqueda"
  match "/bazarcms/enviabusquedaofertas" => "bazarcms/ofertas#enviabusqueda"
  
  match "/bazarcms/borrarconsultas" => "bazarcms/empresasconsultas#borrartodas"
  match "/bazarcms/estadoconsulta/:id" => "bazarcms/empresasconsultas#estado", :constrants => { :id => /\d+/ }
  match "/bazarcms/estadobusqueda" => "bazarcms/empresas#estadobusqueda"
  match "/bazarcms/directorio" => "bazarcms/empresas#list"
  match "/bazarcms/empresas/show2/:id" => "bazarcms/empresas#show2", :constrants => { :id => /\d+/ }
  match "/empresasconsultas2" => "bazarcms/empresasconsultas#empresasconsultas"

  match '/bazarcms/busquedaperfiles' => 'bazarcms/perfiles#busqueda', :as => :busquedaperfiles
  match '/bazarcms/addperfil' => 'bazarcms/perfiles#addperfil', :as => :addperfil
  match '/bazarcms/delperfil' => 'bazarcms/perfiles#delperfil', :as => :delperfil
  match '/bazarcms/listaperfiles' => 'bazarcms/perfiles#listaperfiles', :as => :listaperfiles

  match "/bazarcms/publicaroferta" => 'bazarcms/ofertas#new', :as => :publicaroferta 
  match "/bazarcms/enviaroferta" => 'bazarcms/ofertas#enviaroferta', :as => :enviaroferta 
  match "/bazarcms/buscaofertas" => "bazarcms/ofertas#busca"
  match "/bazarcms/estadobusquedaofertas" => "bazarcms/ofertas#estadobusqueda"
  match "/ofertas.rss" => 'bazarcms/ofertas#rss'
  match "/ofertas2.rss" => 'bazarcms/ofertas#rss2'

  match "/bazarcms/hydra" => 'bazarcms/empresas#hydra', :as => :hydra
  
  match "/ofertas/dashboard" => 'bazarcms/ofertas#dashboard'  
  
  match "/ofertasfavorito/addfav" => "bazarcms/ofertasfavoritos#addfav"
  match "/ofertasfavorito/delfav" => "bazarcms/ofertasfavoritos#delfav"  
  match "/ofertasfavorito/dashboard" => "bazarcms/ofertasfavoritos#dashboard"

  match "/bazarcms/ficharating/:id" => "bazarcms/ratings#ficha", :constrants => { :id => /\d+/ }
  match "/bazarcms/sendrating/:id" => "bazarcms/ratings#sendrating", :constrants => { :id => /\d+/ }
  match "/bazarcms/recrating/" => "bazarcms/ratings#recrating"
  match "/bazarcms/evaluar/:id" => "bazarcms/ratings#evaluar", :constrants => { :id => /\d+/ }
  match "/bazarcms/ratings/evaluado/:id" => "bazarcms/ratings#evaluado", :constrants => { :id => /\d+/ }
    
end