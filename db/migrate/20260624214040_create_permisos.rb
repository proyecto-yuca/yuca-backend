class CreatePermisos < ActiveRecord::Migration[8.1]
  def change
    create_table :permisos do |t|
      t.references :rol,    null: false, foreign_key: { to_table: :roles }
      t.references :modulo, null: false, foreign_key: true
      t.boolean :ver,      null: false, default: false
      t.boolean :crear,    null: false, default: false
      t.boolean :editar,   null: false, default: false
      t.boolean :eliminar, null: false, default: false

      t.timestamps
    end

    add_index :permisos, [ :rol_id, :modulo_id ], unique: true
  end
end
