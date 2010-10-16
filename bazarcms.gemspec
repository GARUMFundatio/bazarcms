# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bazarcms}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.date = %q{2010-10-16}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "app/controllers/bazarcms/empresas_controller.rb",
     "app/helpers/application_helper.rb",
     "app/helpers/bazarcms/bazarcms_helper.rb",
     "app/models/bazarcms/empresa.rb",
     "app/models/bazarcms/empresasdatos.rb",
     "app/views/bazarcms/empresas/index.html.erb",
     "app/views/bazarcms/empresas/show.html.erb",
     "app/views/bazarcms/layouts/bazarcms.html.erb",
     "config/routes.rb",
     "lib/application_helper.rb",
     "lib/bazarcms.rb",
     "lib/bazarcms/engine.rb",
     "lib/bazarcms/rails/generators/bazar_cms/bazarcms_generator.rb",
     "lib/bazarcms/rails/generators/templates/initializer.rb",
     "lib/bazarcms/rails/generators/templates/migration.rb",
     "lib/bazarcms/rails/generators/templates/schema.rb",
     "lib/bazarcms/rails/railties/tasks.rake"
  ]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{bazar_CMS engine  for Rails 3}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

