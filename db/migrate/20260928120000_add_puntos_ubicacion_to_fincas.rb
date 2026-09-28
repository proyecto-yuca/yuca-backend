class AddPuntosUbicacionToFincas < ActiveRecord::Migration[8.1]
  def change
    add_column :fincas, :puntos_ubicacion, :jsonb, default: [], null: false
  end
end
