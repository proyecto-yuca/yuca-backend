class CreateIotCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :iot_credentials do |t|
      t.references :finca, null: false, foreign_key: true, index: { unique: true }
      t.string :client_id, null: false
      t.string :secret_id_digest, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :iot_credentials, :client_id, unique: true
  end
end
