puts "🌱 Limpiando datos existentes..."
Permiso.delete_all
SensorVariable.delete_all
Sensor.delete_all
LecturaSensor.delete_all
IotCredential.delete_all
Cultivo.delete_all
Finca.delete_all
User.delete_all
Modulo.delete_all
Rol.delete_all

# ─── Usuarios ────────────────────────────────────────────────────────────────

puts "👤 Creando usuarios..."

user1 = User.create!(
  name:     "Andrés Felipe Torres",
  email:    "andres.torres@yuca.com",
  password: "password123"
)

user2 = User.create!(
  name:     "María Camila Restrepo",
  email:    "maria.restrepo@yuca.com",
  password: "password123"
)

# ─── Fincas ──────────────────────────────────────────────────────────────────

puts "🏡 Creando fincas..."

fincas_data = [
  {
    user:                    user1,
    nombre:                  "Finca El Paraíso",
    descripcion:             "Terreno con buena irrigación natural y suelos fértiles ideales para cultivo de yuca.",
    area:                    12.5,
    estado:                  "activo",
    fecha_registro:          Date.new(2024, 3, 15),
    departamento:            "Cundinamarca",
    municipio:               "Fusagasugá",
    vereda:                  "El Jordán",
    coordenadas:             "4.3372° N, 74.3641° W",
    direccion_ubicacion:     "Vereda El Jordán, km 3 vía Silvania",
    dueno_nombre:            "Carlos Alberto Ramírez",
    dueno_tipo_documento:    "CC",
    dueno_numero_documento:  "79456123",
    dueno_email:             "carlos.ramirez@email.com",
    dueno_telefono:          "3001234567",
    dueno_direccion:         "Calle 12 #45-23, Fusagasugá"
  },
  {
    user:                    user1,
    nombre:                  "Hacienda La Esperanza",
    descripcion:             "Amplia hacienda con sistema de riego por goteo y cultivos de papa y yuca.",
    area:                    34.8,
    estado:                  "activo",
    fecha_registro:          Date.new(2024, 5, 20),
    departamento:            "Boyacá",
    municipio:               "Tunja",
    vereda:                  "La Chorrera",
    coordenadas:             "5.5353° N, 73.3678° W",
    direccion_ubicacion:     "Vereda La Chorrera, km 7 vía Paipa",
    dueno_nombre:            "Luisa Fernanda Morales",
    dueno_tipo_documento:    "CC",
    dueno_numero_documento:  "52789654",
    dueno_email:             "luisa.morales@email.com",
    dueno_telefono:          "3152345678",
    dueno_direccion:         "Carrera 8 #12-56, Tunja"
  },
  {
    user:                    user1,
    nombre:                  "Finca San Isidro",
    descripcion:             "Finca en zona cálida con alta producción de yuca variedad ICA Costeña.",
    area:                    8.2,
    estado:                  "activo",
    fecha_registro:          Date.new(2024, 7, 3),
    departamento:            "Tolima",
    municipio:               "Espinal",
    vereda:                  "El Cucho",
    coordenadas:             "4.1543° N, 74.8826° W",
    direccion_ubicacion:     "Vereda El Cucho, km 2 carretera al río",
    dueno_nombre:            "Jorge Enrique Patiño",
    dueno_tipo_documento:    "CC",
    dueno_numero_documento:  "91345678",
    dueno_email:             "jorge.patino@email.com",
    dueno_telefono:          "3183456789",
    dueno_direccion:         "Calle 5 #3-21, Espinal"
  },
  {
    user:                    user1,
    nombre:                  "Agrícola Los Pinos",
    descripcion:             "Parcela tecnificada con sensores IoT y sistema de monitoreo continuo.",
    area:                    21.0,
    estado:                  "inactivo",
    fecha_registro:          Date.new(2023, 11, 10),
    departamento:            "Meta",
    municipio:               "Villavicencio",
    vereda:                  "Apiay",
    coordenadas:             "4.1420° N, 73.6266° W",
    direccion_ubicacion:     "Vereda Apiay, finca 14, km 12",
    dueno_nombre:            "Empresa AgroMeta S.A.S",
    dueno_tipo_documento:    "NIT",
    dueno_numero_documento:  "900123456",
    dueno_email:             "gerencia@agrometa.com",
    dueno_telefono:          "6024567890",
    dueno_direccion:         "Cra 30 #38-52 of. 204, Villavicencio"
  },
  {
    user:                    user1,
    nombre:                  "Finca Villa del Río",
    descripcion:             "Cultivos de yuca amarga para producción de almidón industrial.",
    area:                    15.6,
    estado:                  "activo",
    fecha_registro:          Date.new(2024, 1, 28),
    departamento:            "Córdoba",
    municipio:               "Montería",
    vereda:                  "El Cerrito",
    coordenadas:             "8.7575° N, 75.8814° W",
    direccion_ubicacion:     "Vereda El Cerrito, km 5 vía Cereté",
    dueno_nombre:            "Pedro Antonio Díaz",
    dueno_tipo_documento:    "CC",
    dueno_numero_documento:  "73856412",
    dueno_email:             "pedro.diaz@email.com",
    dueno_telefono:          "3004567891",
    dueno_direccion:         "Calle 21 #7-14, Montería"
  },
  {
    user:                    user1,
    nombre:                  "Parcela El Manglar",
    descripcion:             "Zona húmeda con alta biodiversidad, cultivos experimentales de yuca tolerante a inundaciones.",
    area:                    6.0,
    estado:                  "activo",
    fecha_registro:          Date.new(2024, 9, 12),
    departamento:            "Bolívar",
    municipio:               "Mompox",
    vereda:                  "San Martín",
    coordenadas:             "9.2425° N, 74.4264° W",
    direccion_ubicacion:     "Vereda San Martín, ribera río Magdalena",
    dueno_nombre:            "Rosa Inés Herrera",
    dueno_tipo_documento:    "CE",
    dueno_numero_documento:  "E987654",
    dueno_email:             "rosa.herrera@email.com",
    dueno_telefono:          "3205678901",
    dueno_direccion:         "Barrio Centro #4-12, Mompox"
  },
  # Fincas de user2
  {
    user:                    user2,
    nombre:                  "Finca La Montañita",
    descripcion:             "Finca en ladera con cultivos intercalados de yuca y plátano.",
    area:                    9.4,
    estado:                  "activo",
    fecha_registro:          Date.new(2024, 4, 5),
    departamento:            "Antioquia",
    municipio:               "Rionegro",
    vereda:                  "La Aldea",
    coordenadas:             "6.1552° N, 75.3739° W",
    direccion_ubicacion:     "Vereda La Aldea, km 4 vía El Peñol",
    dueno_nombre:            "Hernán Darío Ospina",
    dueno_tipo_documento:    "CC",
    dueno_numero_documento:  "71234567",
    dueno_email:             "hernan.ospina@email.com",
    dueno_telefono:          "3017891234",
    dueno_direccion:         "Carrera 50 #49-01, Rionegro"
  },
  {
    user:                    user2,
    nombre:                  "Agrícola El Porvenir",
    descripcion:             "Gran extensión con producción de yuca para exportación procesada.",
    area:                    50.3,
    estado:                  "activo",
    fecha_registro:          Date.new(2023, 8, 17),
    departamento:            "Valle del Cauca",
    municipio:               "Palmira",
    vereda:                  "Boyacá",
    coordenadas:             "3.5394° N, 76.3036° W",
    direccion_ubicacion:     "Vereda Boyacá, km 8 vía Pradera",
    dueno_nombre:            "Inversiones Agro Valle S.A.",
    dueno_tipo_documento:    "NIT",
    dueno_numero_documento:  "800987654",
    dueno_email:             "info@agrovalle.com",
    dueno_telefono:          "6022345678",
    dueno_direccion:         "Av. 4N #23-15, Palmira"
  }
]

fincas = fincas_data.map { |data| Finca.create!(data) }
puts "   ✓ #{fincas.size} fincas creadas"

# ─── Lecturas de Sensores ────────────────────────────────────────────────────

puts "📡 Creando lecturas de sensores..."

sensores     = %w[SHT-3x-A DHT-22 BME280 SHT-31B]
horas_dia    = %w[06:00 12:00 18:00 23:00]
total_lecturas = 0

fincas.each do |finca|
  sensor_id = sensores.sample

  # Lecturas de los últimos 30 días
  (0..29).each do |dias_atras|
    fecha = Date.today - dias_atras

    horas_dia.each_with_index do |hora, idx|
      # Simular valores realistas según la hora del día
      base_humedad     = 60 + rand(-15..20).to_f + (idx * 2)
      base_temperatura = 22 + rand(-5..10).to_f - (idx == 0 ? 3 : 0)

      humedad     = base_humedad.clamp(25.0, 98.0).round(1)
      temperatura = base_temperatura.clamp(8.0, 40.0).round(1)

      next if LecturaSensor.exists?(finca_id: finca.id, fecha: fecha, hora_registro: hora)

      LecturaSensor.create!(
        finca:         finca,
        sensor_id:     sensor_id,
        fecha:         fecha,
        hora_registro: hora,
        humedad:       humedad,
        temperatura:   temperatura
      )
      total_lecturas += 1
    end
  end
end

puts "   ✓ #{total_lecturas} lecturas creadas"

puts ""
puts "✅ Seeds completados:"
puts "   • #{User.count} usuarios"
puts "   • #{Finca.count} fincas (#{Finca.where(estado: 'activo').count} activas, #{Finca.where(estado: 'inactivo').count} inactivas)"
puts "   • #{LecturaSensor.count} lecturas de sensores"
puts "   • Alertas: #{LecturaSensor.where(estado: 'alerta').count} | Críticos: #{LecturaSensor.where(estado: 'critico').count} | Normales: #{LecturaSensor.where(estado: 'normal').count}"
puts ""

load Rails.root.join("db/seeds/iot_credentials.rb")
load Rails.root.join("db/seeds/permisos.rb")

puts "🔑 Credenciales:"
puts "   andres.torres@yuca.com   /  password123  (6 fincas)"
puts "   maria.restrepo@yuca.com  /  password123  (2 fincas)"
# "owner@owner.com / password123"
puts ""
puts "   • #{Rol.count} roles  |  #{Modulo.count} módulos  |  #{Permiso.count} permisos"
