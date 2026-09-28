class CreateAlertas < ActiveRecord::Migration[8.1]
  def change
    create_table :alertas do |t|
      t.references :lectura,         null: false, foreign_key: true
      t.references :variable_evento, null: false, foreign_key: true
      t.references :sensor,          null: false, foreign_key: { to_table: :sensores }
      t.references :variable,        null: false, foreign_key: true
      t.references :finca,           null: false, foreign_key: true
      t.string   :tipo,      null: false
      t.string   :severidad, null: false
      t.decimal  :valor,     precision: 8, scale: 2, null: false
      t.decimal  :rango_min, precision: 8, scale: 2
      t.decimal  :rango_max, precision: 8, scale: 2
      t.datetime :email_enviado_at
      t.string   :emails_enviados, array: true, null: false, default: []
      t.boolean  :notificacion_omitida, null: false, default: false
      t.string   :motivo_omision
      t.text     :error_envio

      t.timestamps
    end

    add_index :alertas, [ :sensor_id, :variable_evento_id, :created_at ]
    add_index :alertas, [ :finca_id, :created_at ]
    add_index :alertas, [ :lectura_id, :variable_evento_id ], unique: true
  end
end
