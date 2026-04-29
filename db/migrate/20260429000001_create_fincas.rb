class CreateFincas < ActiveRecord::Migration[8.1]
  def change
    create_table :fincas do |t|
      t.string  :nombre,                  null: false
      t.text    :descripcion
      t.decimal :area,                    null: false, precision: 10, scale: 2
      t.string  :estado,                  null: false, default: "activo"
      t.date    :fecha_registro,          null: false

      # Ubicación
      t.string  :departamento,            null: false
      t.string  :municipio,               null: false
      t.string  :vereda
      t.string  :coordenadas
      t.string  :direccion_ubicacion

      # Dueño
      t.string  :dueno_nombre,            null: false
      t.string  :dueno_tipo_documento,    null: false
      t.string  :dueno_numero_documento,  null: false
      t.string  :dueno_email,             null: false
      t.string  :dueno_telefono,          null: false
      t.string  :dueno_direccion

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :fincas, :estado
    add_index :fincas, :municipio
    add_index :fincas, :departamento
    add_index :fincas, [ :user_id, :estado ]
  end
end
