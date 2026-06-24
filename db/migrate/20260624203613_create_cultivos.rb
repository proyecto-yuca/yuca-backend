class CreateCultivos < ActiveRecord::Migration[8.1]
  def change
    create_table :cultivos do |t|
      t.string :nombre, null: false
      t.text :descripcion
      t.jsonb :puntos_ubicacion, null: false, default: []
      t.references :finca, null: false, foreign_key: true

      t.timestamps
    end

  end
end
