class CreateLecturas < ActiveRecord::Migration[8.1]
  def change
    create_table :lecturas do |t|
      t.references :sensor,   null: false, foreign_key: { to_table: :sensores }
      t.references :variable, null: false, foreign_key: true
      t.decimal    :valor,    null: false, precision: 8, scale: 2
      t.date       :fecha,        null: false
      t.string     :hora_registro, null: false

      t.timestamps
    end

    add_index :lecturas, [ :sensor_id, :fecha ]
    add_index :lecturas, [ :sensor_id, :variable_id, :fecha, :hora_registro ],
              unique: true, name: "index_lecturas_unicidad"
  end
end
