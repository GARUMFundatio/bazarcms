namespace :bazarcms do
  
  desc "para las tareas que tengamos que ejecutar"
  task :report => :environment do
    puts "esto sería un report"
  end

end