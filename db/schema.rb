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

ActiveRecord::Schema[8.1].define(version: 2026_07_23_120001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cultivos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.bigint "finca_id", null: false
    t.string "nombre", null: false
    t.jsonb "puntos_ubicacion", default: [], null: false
    t.datetime "updated_at", null: false
    t.index ["finca_id"], name: "index_cultivos_on_finca_id"
  end

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

  create_table "iot_credentials", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "client_id", null: false
    t.datetime "created_at", null: false
    t.bigint "finca_id", null: false
    t.datetime "last_synced_at"
    t.string "secret_id_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_iot_credentials_on_client_id", unique: true
    t.index ["finca_id"], name: "index_iot_credentials_on_finca_id", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "lecturas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "fecha", null: false
    t.string "hora_registro", null: false
    t.bigint "sensor_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 8, scale: 2, null: false
    t.bigint "variable_id", null: false
    t.index ["sensor_id", "fecha"], name: "index_lecturas_on_sensor_id_and_fecha"
    t.index ["sensor_id", "variable_id", "fecha", "hora_registro"], name: "index_lecturas_unicidad", unique: true
    t.index ["sensor_id"], name: "index_lecturas_on_sensor_id"
    t.index ["variable_id"], name: "index_lecturas_on_variable_id"
  end

  create_table "modulos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "identificador", null: false
    t.string "nombre", null: false
    t.integer "orden", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["identificador"], name: "index_modulos_on_identificador", unique: true
  end

  create_table "permisos", force: :cascade do |t|
    t.boolean "crear", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "editar", default: false, null: false
    t.boolean "eliminar", default: false, null: false
    t.bigint "modulo_id", null: false
    t.bigint "rol_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "ver", default: false, null: false
    t.index ["modulo_id"], name: "index_permisos_on_modulo_id"
    t.index ["rol_id", "modulo_id"], name: "index_permisos_on_rol_id_and_modulo_id", unique: true
    t.index ["rol_id"], name: "index_permisos_on_rol_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.string "identificador", null: false
    t.string "nombre", null: false
    t.boolean "sistema", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["identificador"], name: "index_roles_on_identificador", unique: true
  end

  create_table "sensor_variables", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "sensor_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "variable_id", null: false
    t.index ["sensor_id", "variable_id"], name: "index_sensor_variables_on_sensor_id_and_variable_id", unique: true
    t.index ["sensor_id"], name: "index_sensor_variables_on_sensor_id"
    t.index ["variable_id"], name: "index_sensor_variables_on_variable_id"
  end

  create_table "sensores", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.string "codigo", null: false
    t.datetime "created_at", null: false
    t.bigint "cultivo_id"
    t.text "descripcion"
    t.bigint "finca_id", null: false
    t.decimal "lat", precision: 10, scale: 7
    t.decimal "lng", precision: 10, scale: 7
    t.string "nombre", null: false
    t.datetime "updated_at", null: false
    t.index ["cultivo_id"], name: "index_sensores_on_cultivo_id"
    t.index ["finca_id", "codigo"], name: "index_sensores_on_finca_id_and_codigo", unique: true
    t.index ["finca_id"], name: "index_sensores_on_finca_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "estado", default: true, null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.bigint "rol_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["estado"], name: "index_users_on_estado"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["rol_id"], name: "index_users_on_rol_id"
  end

  create_table "variables", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "decimales", default: 2, null: false
    t.text "descripcion"
    t.string "nombre", null: false
    t.string "unidad", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_variables_on_nombre", unique: true
  end

  add_foreign_key "cultivos", "fincas"
  add_foreign_key "fincas", "users"
  add_foreign_key "iot_credentials", "fincas"
  add_foreign_key "lecturas", "sensores", column: "sensor_id"
  add_foreign_key "lecturas", "variables"
  add_foreign_key "permisos", "modulos"
  add_foreign_key "permisos", "roles", column: "rol_id"
  add_foreign_key "sensor_variables", "sensores", column: "sensor_id"
  add_foreign_key "sensor_variables", "variables"
  add_foreign_key "sensores", "cultivos"
  add_foreign_key "sensores", "fincas"
  add_foreign_key "users", "roles", column: "rol_id"
end
