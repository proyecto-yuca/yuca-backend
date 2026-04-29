# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_29_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "fincas", force: :cascade do |t|
    t.decimal "area", precision: 10, scale: 2, null: false
    t.string "coordenadas"
    t.datetime "created_at", null: false
    t.string "departamento", null: false
    t.text "descripcion"
    t.string "direccion_ubicacion"
    t.string "dueno_direccion"
    t.string "dueno_email", null: false
    t.string "dueno_nombre", null: false
    t.string "dueno_numero_documento", null: false
    t.string "dueno_telefono", null: false
    t.string "dueno_tipo_documento", null: false
    t.string "estado", default: "activo", null: false
    t.date "fecha_registro", null: false
    t.string "municipio", null: false
    t.string "nombre", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "vereda"
    t.index "to_tsvector('spanish'::regconfig, (((((((COALESCE(nombre, ''::character varying))::text || ' '::text) || (COALESCE(municipio, ''::character varying))::text) || ' '::text) || (COALESCE(departamento, ''::character varying))::text) || ' '::text) || (COALESCE(dueno_nombre, ''::character varying))::text))", name: "index_fincas_on_search_vector", using: :gin
    t.index ["departamento"], name: "index_fincas_on_departamento"
    t.index ["estado"], name: "index_fincas_on_estado"
    t.index ["municipio"], name: "index_fincas_on_municipio"
    t.index ["user_id", "estado"], name: "index_fincas_on_user_id_and_estado"
    t.index ["user_id"], name: "index_fincas_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "lecturas_sensor", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "estado", null: false
    t.date "fecha", null: false
    t.bigint "finca_id", null: false
    t.string "hora_registro", null: false
    t.decimal "humedad", precision: 5, scale: 1, null: false
    t.string "sensor_id", null: false
    t.decimal "temperatura", precision: 5, scale: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["finca_id", "estado"], name: "index_lecturas_sensor_on_finca_id_and_estado"
    t.index ["finca_id", "fecha", "hora_registro"], name: "index_lecturas_sensor_on_finca_id_and_fecha_and_hora_registro", unique: true
    t.index ["finca_id", "fecha"], name: "index_lecturas_sensor_on_finca_id_and_fecha"
    t.index ["finca_id"], name: "index_lecturas_sensor_on_finca_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "fincas", "users"
  add_foreign_key "lecturas_sensor", "fincas"
end
