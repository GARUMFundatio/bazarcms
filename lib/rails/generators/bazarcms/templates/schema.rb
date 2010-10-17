ActiveRecord::Schema.define(:version => 0) do

    create_table :empresas, :force => true do |t|
      t.integer :user_id
      t.string  :nombre
      t.text    :desc
      t.integer :fundada  
      t.datetime  :created_at
      t.datetime  :updated_at
    end

    add_index :empresas, [:user_id]
    
    create_table  :empresasdatos, :force => true do |t|
      t.integer   :empresa_id
      t.integer   :periodo
      t.float     :ventas
      t.float     :compras  
      t.datetime  :created_at
      t.datetime  :updated_at
    end

    add_index :empresasdatos, [:empresa_id]

end