ActiveRecord::Schema.define(:version => 0) do

    create_table :bazar_cms, :force => true do |t|
      t.integer :user_id
      t.string  :nombre
      t.text    :desc
      t.int     :fundada  
      t.datetime  :created_at
      t.datetime  :updated_at
    end

    add_index :bazar_cms, [:user_id]
    
    create_table  :bazar_cms_data, :force => true do |t|
      t.integer   :bazarcms_id
      t.integer   :periodo
      t.float     :ventas
      t.float     :compras  
      t.datetime  :created_at
      t.datetime  :updated_at
    end

    add_index :bazar_cms_data, [:bazar_cms_id]

end