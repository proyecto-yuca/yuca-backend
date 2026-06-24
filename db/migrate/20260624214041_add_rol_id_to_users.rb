class AddRolIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :rol, null: true, foreign_key: { to_table: :roles }
  end
end
