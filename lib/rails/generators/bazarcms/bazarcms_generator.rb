require 'rails/generators'
require 'rails/generators/migration'

class BazarcmsGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end
   
  def self.next_migration_number(dirname) #:nodoc:
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end


  # Every method that is declared below will be automatically executed when the generator is run
  
  def create_migration_file
  
    f = File.open File.join(File.dirname(__FILE__), 'templates', 'schema.rb')
    schema = f.read; f.close
    
    schema.gsub!(/ActiveRecord::Schema.*\n/, '')
    schema.gsub!(/^end\n*$/, '')

    f = File.open File.join(File.dirname(__FILE__), 'templates', 'migration.rb')
    migration = f.read; f.close
    migration.gsub!(/SCHEMA_AUTO_INSERTED_HERE/, schema)
    
    tmp = File.open "tmp/~migration_ready.rb", "w"
    tmp.write migration
    tmp.close

# vemos si ya existe un fichero de migracion v1
    existe = false; 
    Dir.foreach("db/migrate") { |f|
      if File.fnmatch('*_create_bazarcms_tables.rb', f) then
        puts 'existe!!!!'
        existe = true
        end
      }
  
    if (existe == false) then
      migration_template  '../../../tmp/~migration_ready.rb','db/migrate/create_bazarcms_tables.rb'
    end
    remove_file 'tmp/~migration_ready.rb'      


    for i in 2..4
      # vemos si ya existe un fichero de migracion vN ubicaciones
      existe = false; 
      Dir.foreach("db/migrate") { |f|
        if File.fnmatch('*_create_bazarcms_tables'+i.to_s+'.rb', f) then
          puts 'existe!!!!'
          existe = true
        end
      }

        if (existe == false) then
          migration_template  File.join(File.dirname(__FILE__), 'templates', 'schema'+i.to_s+'.rb'),'db/migrate/create_bazarcms_tables'+i.to_s+'.rb'
        end
    end
end

  def copy_initializer_file
    copy_file 'initializer.rb', 'config/initializers/bazarcms.rb'
  end


def update_application_template


layout = '  <% content_for :bazarcontent do %>
    <%= stylesheet_link_tag("bazarcms") %>
    <div> 
      <%= yield %>
    </div>
  <% end -%>
<%= render :file => "layouts/bazar" %>
';
  
tmp = File.open "tmp/~application.html.erb", "w"
tmp.write layout; tmp.close

# remove_file 'app/views/layouts/application.html.erb'
copy_file '../../../tmp/~application.html.erb', 'app/views/layouts/bazarcms.html.erb'
remove_file 'tmp/~application.html.erb'



#    f = File.open "app/views/layouts/application.html.erb"
#    layout = f.read; f.close
    
#    if layout =~ /<%=[ ]+yield[ ]+%>/
#      print "    \e[1m\e[34mquestion\e[0m  Your layouts/application.html.erb layout currently has the line <%= yield %>. This gem needs to change this line to <%= content_for?(:content) ? yield(:content) : yield %> to support its nested layouts. This change should not affect any of your existing layouts or views. Is this okay? [y/n] "
#      begin
#        answer = gets.chomp
#      end while not answer =~ /[yn]/i
      
#      if answer =~ /y/i
        
 #       layout.gsub!(/<%=[ ]+yield[ ]+%>/, '<%= content_for?(:content) ? yield(:content) : yield %>')

 #       tmp = File.open "tmp/~application.html.erb", "w"
 #       tmp.write layout; tmp.close

 #       remove_file 'app/views/layouts/application.html.erb'
 #       copy_file '../../../tmp/~application.html.erb', 
#                  'app/views/layouts/application.html.erb'
#        remove_file 'tmp/~application.html.erb'
#      end
#    elsif layout =~ /<%=[ ]+content_for\?\(:content\) \? yield\(:content\) : yield[ ]+%>/
#      puts "    \e[1m\e[33mskipping\e[0m  layouts/application.html.erb modification is already done."
#    else
#      puts "    \e[1m\e[31mconflict\e[0m  The gem is confused by your layouts/application.html.erb. It does not contain the default line <%= yield %>, you may need to make manual changes to get this gem's nested layouts working. Visit ###### for details."
#    end

end
  
end
