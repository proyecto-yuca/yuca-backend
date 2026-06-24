class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :identificador, null: false
      t.string :nombre, null: false
      t.text :descripcion
      t.boolean :sistema, null: false, default: false

      t.timestamps
    end

    add_index :roles, :identificador, unique: true
  end
end
