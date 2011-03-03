class CreateBazarcmsTables5 < ActiveRecord::Migration

  def self.up  
    create_table :perfiles, :force => true do |t|
      t.string   :codigo
      t.string   :desc
      t.integer  :nivel
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :perfiles, [:codigo]
  
  end

  def self.down
    
  end

end
