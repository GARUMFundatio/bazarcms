# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bazarcms}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Garum Fundatio"]
  s.date = %q{2011-03-06}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "app/controllers/bazarcms/empresas_controller.rb",
     "app/controllers/bazarcms/empresasconsultas_controller.rb",
     "app/controllers/bazarcms/empresasdatos_controller.rb",
     "app/controllers/bazarcms/empresasperfiles_controller.rb",
     "app/controllers/bazarcms/empresasresultados_controller.rb",
     "app/controllers/bazarcms/perfiles_controller.rb",
     "app/controllers/bazarcms/ubicaciones_controller.rb",
     "app/helpers/application_helper.rb",
     "app/helpers/bazarcms/bazarcms_helper.rb",
     "app/models/bazarcms/empresa.rb",
     "app/models/bazarcms/empresasconsulta.rb",
     "app/models/bazarcms/empresasdato.rb",
     "app/models/bazarcms/empresasperfil.rb",
     "app/models/bazarcms/empresasresultado.rb",
     "app/models/bazarcms/perfil.rb",
     "app/models/bazarcms/ubicacion.rb",
     "app/views/bazarcms/empresas/busca.html.erb",
     "app/views/bazarcms/empresas/buscador.html.erb",
     "app/views/bazarcms/empresas/dashboard.html.erb",
     "app/views/bazarcms/empresas/edit.html.erb",
     "app/views/bazarcms/empresas/enviabusqueda.html.erb",
     "app/views/bazarcms/empresas/index.html.erb",
     "app/views/bazarcms/empresas/list.html.erb",
     "app/views/bazarcms/empresas/resultado.html.erb",
     "app/views/bazarcms/empresas/show.html.erb",
     "app/views/bazarcms/empresas/show2.html.erb",
     "app/views/bazarcms/empresasconsultas/estado.html.erb",
     "app/views/bazarcms/empresasconsultas/index.html.erb",
     "app/views/bazarcms/empresasconsultas/show.html.erb",
     "app/views/bazarcms/empresasdatos/edit.html.erb",
     "app/views/bazarcms/layouts/bazarcms.html.erb",
     "app/views/bazarcms/perfiles/listaperfiles.html.erb",
     "app/views/bazarcms/ubicaciones/_form.html.erb",
     "app/views/bazarcms/ubicaciones/edit.html.erb",
     "app/views/bazarcms/ubicaciones/index.html.erb",
     "app/views/bazarcms/ubicaciones/new.html.erb",
     "app/views/bazarcms/ubicaciones/show.html.erb",
     "config/routes.rb",
     "lib/application_helper.rb",
     "lib/bazarcms.rb",
     "lib/engine.rb",
     "lib/rails/generators/bazarcms/bazarcms_generator.rb",
     "lib/rails/generators/bazarcms/templates/initializer.rb",
     "lib/rails/generators/bazarcms/templates/migration.rb",
     "lib/rails/generators/bazarcms/templates/schema.rb",
     "lib/rails/generators/bazarcms/templates/schema2.rb",
     "lib/rails/generators/bazarcms/templates/schema3.rb",
     "lib/rails/generators/bazarcms/templates/schema4.rb",
     "lib/rails/generators/bazarcms/templates/schema5.rb",
     "lib/rails/generators/bazarcms/templates/schema6.rb",
     "lib/rails/railties/tasks.rake",
     "public/stylesheets/bazarcms.css"
  ]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{bazarcms engine for Rails 3}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

