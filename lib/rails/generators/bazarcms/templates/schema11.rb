class AddPhotoToUser < ActiveRecord::Migration
  def self.up
    add_column :empresas, :logo_file_name, :string 
    add_column :empresas, :logo_content_type, :string 
    add_column :empresas, :logo_file_size, :integer
  end

  def self.down
    remove_column :empresas, :logo_file_name
    remove_column :empresas, :logo_content_type
    remove_column :empresas, :logo_file_size
  end

end