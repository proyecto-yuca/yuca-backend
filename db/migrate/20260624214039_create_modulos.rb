class CreateModulos < ActiveRecord::Migration[8.1]
  def change
    create_table :modulos do |t|
      t.string :identificador, null: false
      t.string :nombre, null: false
      t.integer :orden, null: false, default: 0

      t.timestamps
    end

    add_index :modulos, :identificador, unique: true
  end
end
