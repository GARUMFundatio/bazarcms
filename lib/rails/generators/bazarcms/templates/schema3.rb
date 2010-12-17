class CreateBazarcmsTables3 < ActiveRecord::Migration
  def self.up

    create_table :empresasconsultas, :force => true do |t|
      t.integer  :user_id
      t.string   :desc
      t.integer  :total_consultas
      t.integer  :total_respuestas
      t.datetime :fecha_inicio
      t.datetime :fecha_fin
      t.text     :sql
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :empresasconsultas, [:user_id, :fecha_inicio]

    create_table :empresasresultados, :force => true do |t|
      t.integer  :consulta_id
      t.integer  :cluster_id
      t.integer  :empresa_id
      t.string   :orden
      t.string   :enlace
      t.string   :info
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :empresasresultados, [:consulta_id, :orden]

  end

  def self.down
    drop_table :ubicaciones
  end

end