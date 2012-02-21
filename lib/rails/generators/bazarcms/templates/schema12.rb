class CreateBazarcmsTables12 < ActiveRecord::Migration
  def self.up
    add_column :empresas, :sector, :string 
    add_column :empresas, :color, :string 
    add_column :empresas, :ambito, :string
    add_column :empresas, :linkedin, :string
    add_column :empresas, :facebook, :string
    
    add_column :ofertas, :ambito, :string
    add_column :ofertas, :sector, :string
    
    create_table :empresasimagenes, :force => true do |t|
      t.integer  :empresa_id
      t.integer  :orden
      t.has_attached_file :imagen
    end

    add_index :empresasimagenes, [:empresa_id]

    create_table :ofertasimagenes, :force => true do |t|
      t.integer  :oferta_id
      t.integer  :orden
      t.has_attached_file :imagen
    end

    add_index :ofertasimagenes, [:oferta_id]
    
  end

  def self.down
    remove_column :empresas, :sector
    remove_column :empresas, :color
    remove_column :empresas, :ambito
    remove_column :empresas, :linkedin
    remove_column :empresas, :facebook
    remove_column :empresas, :google
    
    remove_column :ofertas, :ambito
    remove_column :ofertas, :sector
    
    
  end

end