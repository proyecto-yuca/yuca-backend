class DropLecturasSensor < ActiveRecord::Migration[8.1]
  def up
    drop_table :lecturas_sensor
  end

  def down
    create_table :lecturas_sensor do |t|
      t.references :finca,        null: false, foreign_key: true
      t.string     :sensor_id,    null: false
      t.date       :fecha,        null: false
      t.string     :hora_registro, null: false
      t.decimal    :humedad,      null: false, precision: 5, scale: 1
      t.decimal    :temperatura,  null: false, precision: 5, scale: 1
      t.string     :estado,       null: false

      t.timestamps
    end

    add_index :lecturas_sensor, [ :finca_id, :fecha ]
    add_index :lecturas_sensor, [ :finca_id, :estado ]
    add_index :lecturas_sensor, [ :finca_id, :fecha, :hora_registro ], unique: true
  end
end
