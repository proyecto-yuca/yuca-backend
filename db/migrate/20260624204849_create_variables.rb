class CreateVariables < ActiveRecord::Migration[8.1]
  def change
    create_table :variables do |t|
      t.string :nombre, null: false
      t.string :unidad, null: false
      t.integer :decimales, null: false, default: 2
      t.text :descripcion

      t.timestamps
    end

    add_index :variables, :nombre, unique: true
  end
end
