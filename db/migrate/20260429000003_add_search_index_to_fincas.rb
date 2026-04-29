class AddSearchIndexToFincas < ActiveRecord::Migration[8.1]
  def change
    add_index :fincas,
      "to_tsvector('spanish', coalesce(nombre,'') || ' ' ||
                               coalesce(municipio,'') || ' ' ||
                               coalesce(departamento,'') || ' ' ||
                               coalesce(dueno_nombre,''))",
      using: :gin,
      name: "index_fincas_on_search_vector"
  end
end
