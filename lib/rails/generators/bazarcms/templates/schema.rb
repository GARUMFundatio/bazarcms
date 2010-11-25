ActiveRecord::Schema.define(:version => 20101112073536) do

    create_table :empresas, :force => true do |t|
      t.integer  :user_id
      t.string   :nombre
      t.text     :desc
      t.integer  :fundada  
      t.integer  :moneda
      t.datetime  :created_at
      t.datetime  :updated_at
    end

    add_index :empresas, [:user_id]
    
    create_table  :empresasdatos, :force => true do |t|
      t.integer   :empresa_id
      t.integer   :periodo
      t.integer   :empleados
      t.integer   :ventas
      t.integer   :compras
      t.integer   :resultados  
      t.datetime  :created_at
      t.datetime  :updated_at
    end

    add_index :empresasdatos, [:empresa_id, :periodo]

end