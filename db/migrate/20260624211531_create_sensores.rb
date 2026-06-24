class CreateSensores < ActiveRecord::Migration[8.1]
  def change
    create_table :sensores do |t|
      t.string :codigo, null: false
      t.string :nombre, null: false
      t.text :descripcion
      t.decimal :lat, precision: 10, scale: 7
      t.decimal :lng, precision: 10, scale: 7
      t.boolean :activo, null: false, default: true
      t.references :finca, null: false, foreign_key: true
      t.references :cultivo, null: true, foreign_key: true

      t.timestamps
    end

    add_index :sensores, [ :finca_id, :codigo ], unique: true
  end
end
