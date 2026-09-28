class CreateVariableEventos < ActiveRecord::Migration[8.1]
  def change
    create_table :variable_eventos do |t|
      t.references :variable, null: false, foreign_key: true
      t.string  :nombre,    null: false
      t.string  :severidad, null: false, default: "alerta"
      t.decimal :rango_min, precision: 8, scale: 2
      t.decimal :rango_max, precision: 8, scale: 2
      t.boolean :notificar_email, null: false, default: true
      t.string  :emails, array: true, null: false, default: []
      t.integer :intervalo_minutos, null: false, default: 60
      t.boolean :activo, null: false, default: true

      t.timestamps
    end

    add_index :variable_eventos, [ :variable_id, :nombre ], unique: true
  end
end
