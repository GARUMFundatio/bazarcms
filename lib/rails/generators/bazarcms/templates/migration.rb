class CreateBazarcmsTables < ActiveRecord::Migration
  def self.up
    SCHEMA_AUTO_INSERTED_HERE
  end

  def self.down
    drop_table :empresas
    drop_table :empresasdatos
    
  end
end