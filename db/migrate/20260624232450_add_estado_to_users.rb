class AddEstadoToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :estado, :boolean, null: false, default: true
    add_index  :users, :estado
  end
end
