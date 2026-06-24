class CreateSensorVariables < ActiveRecord::Migration[8.1]
  def change
    create_table :sensor_variables do |t|
      t.references :sensor, null: false, foreign_key: { to_table: :sensores }
      t.references :variable, null: false, foreign_key: true

      t.timestamps
    end

    add_index :sensor_variables, [ :sensor_id, :variable_id ], unique: true
  end
end
