# Datos compartidos por los tests de eventos y alertas.
module SupportAlertas
  def crear_escenario_alertas
    user = User.create!(email: "alertas-#{SecureRandom.hex(4)}@yuca.com", password: "password123")
    @finca = Finca.create!(
      user: user, nombre: "Agrícola Test", area: 10, departamento: "Valle del Cauca", municipio: "Palmira",
      dueno_nombre: "Dueño", dueno_tipo_documento: "CC", dueno_numero_documento: "123",
      dueno_email: "dueno@yuca.com", dueno_telefono: "3000000000"
    )
    @cultivo  = @finca.cultivos.create!(nombre: "Lote Sur")
    @variable = Variable.create!(nombre: "Humedad #{SecureRandom.hex(3)}", unidad: "%", decimales: 1)
    @sensor   = @finca.sensores.create!(codigo: "SHT-#{SecureRandom.hex(2)}", nombre: "Sensor Sur", cultivo: @cultivo)
    @optimo   = @variable.eventos.create!(nombre: "Fuera de óptimo", severidad: "alerta", rango_min: 40, rango_max: 80,
                                          emails: [ "agronomo@yuca.com" ])
    @critico  = @variable.eventos.create!(nombre: "Crítica", severidad: "critico", rango_min: 30, rango_max: 90,
                                          emails: [ "agronomo@yuca.com", "gerencia@yuca.com" ])
    @hora = 0
  end

  def crear_lectura(valor)
    @hora += 1
    Lectura.create!(sensor: @sensor, variable: @variable, fecha: Date.current,
                    hora_registro: format("%02d:00", @hora % 24), valor: valor)
  end
end
