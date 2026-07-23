# bin/rails runner 'load Rails.root.join("db/seeds/lecturas_el_porvenir.rb")'

puts "🌾 Creando cultivos, sensores y lecturas para Agrícola El Porvenir..."

finca = Finca.find_by!(nombre: "Agrícola El Porvenir")

# ─── Variables ────────────────────────────────────────────────────────────────

humedad = Variable.find_or_create_by!(nombre: "Humedad") do |v|
  v.unidad = "%"
  v.decimales = 1
  v.descripcion = "Humedad relativa del suelo"
end

temperatura = Variable.find_or_create_by!(nombre: "Temperatura") do |v|
  v.unidad = "°C"
  v.decimales = 1
  v.descripcion = "Temperatura ambiente"
end

luminosidad = Variable.find_or_create_by!(nombre: "Luminosidad") do |v|
  v.unidad = "lux"
  v.decimales = 0
  v.descripcion = "Intensidad de luz solar"
end

# ─── Cultivos ─────────────────────────────────────────────────────────────────

cultivos_data = [
  {
    nombre:      "Lote Norte",
    descripcion: "Sector norte de la finca, yuca variedad ICA Costeña.",
    puntos_ubicacion: [
      { "lat" => "3.5410", "lng" => "-76.3050" },
      { "lat" => "3.5418", "lng" => "-76.3032" },
      { "lat" => "3.5402", "lng" => "-76.3020" },
      { "lat" => "3.5395", "lng" => "-76.3041" }
    ]
  },
  {
    nombre:      "Lote Sur",
    descripcion: "Sector sur de la finca, yuca amarga para procesamiento industrial.",
    puntos_ubicacion: [
      { "lat" => "3.5370", "lng" => "-76.3055" },
      { "lat" => "3.5378", "lng" => "-76.3038" },
      { "lat" => "3.5362", "lng" => "-76.3025" },
      { "lat" => "3.5356", "lng" => "-76.3047" }
    ]
  }
]

cultivos = cultivos_data.map do |data|
  Cultivo.find_or_create_by!(finca: finca, nombre: data[:nombre]) do |c|
    c.descripcion = data[:descripcion]
    c.puntos_ubicacion = data[:puntos_ubicacion]
  end
end

# ─── Sensores ─────────────────────────────────────────────────────────────────

sensores_data = [
  { cultivo: cultivos[0], codigo: "LN-SHT-01", nombre: "Sensor Humedad Norte",  variables: [ humedad, temperatura ] },
  { cultivo: cultivos[0], codigo: "LN-BME-02", nombre: "Sensor Ambiente Norte", variables: [ temperatura, luminosidad ] },
  { cultivo: cultivos[1], codigo: "LS-SHT-01", nombre: "Sensor Humedad Sur",    variables: [ humedad ] },
  { cultivo: cultivos[1], codigo: "LS-BME-02", nombre: "Sensor Ambiente Sur",   variables: [ humedad, temperatura, luminosidad ] }
]

sensores = sensores_data.map do |data|
  sensor = Sensor.find_or_create_by!(finca: finca, codigo: data[:codigo]) do |s|
    s.nombre = data[:nombre]
    s.cultivo = data[:cultivo]
    s.activo = true
  end
  sensor.variables = data[:variables]
  sensor
end

# ─── Lecturas (últimos 30 días) ───────────────────────────────────────────────

horas_dia = %w[06:00 12:00 18:00 23:00]
total_lecturas = 0

valor_realista = lambda do |variable_nombre, idx|
  case variable_nombre
  when "Humedad"
    (60 + rand(-15..20).to_f + (idx * 2)).clamp(25.0, 98.0).round(1)
  when "Temperatura"
    (24 + rand(-5..8).to_f - (idx == 0 ? 3 : 0)).clamp(10.0, 38.0).round(1)
  when "Luminosidad"
    (idx.zero? || idx == 3 ? rand(0..500) : rand(3000..12000)).to_f.round(0)
  else
    rand(0.0..100.0).round(1)
  end
end

sensores.each do |sensor|
  (0..29).each do |dias_atras|
    fecha = Date.today - dias_atras

    horas_dia.each_with_index do |hora, idx|
      sensor.variables.each do |variable|
        next if Lectura.exists?(sensor_id: sensor.id, variable_id: variable.id, fecha: fecha, hora_registro: hora)

        Lectura.create!(
          sensor:        sensor,
          variable:      variable,
          fecha:         fecha,
          hora_registro: hora,
          valor:         valor_realista.call(variable.nombre, idx)
        )
        total_lecturas += 1
      end
    end
  end
end

puts "   ✓ #{cultivos.size} cultivos, #{sensores.size} sensores, #{total_lecturas} lecturas creadas para #{finca.nombre}"
puts ""
