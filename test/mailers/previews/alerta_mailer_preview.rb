# Previews en http://localhost:3000/rails/mailers/alerta_mailer
# Construye los registros en memoria: no escribe en la base.
class AlertaMailerPreview < ActionMailer::Preview
  def critico
    AlertaMailer.with(alerta: alerta_de_ejemplo(severidad: "critico", valor: 95.2, min: 30, max: 90, evento: "Humedad crítica"))
                .fuera_de_rango([ "agronomo@yuca.com", "gerencia@yuca.com" ])
  end

  def alerta
    AlertaMailer.with(alerta: alerta_de_ejemplo(severidad: "alerta", valor: 36.4, min: 40, max: 80, evento: "Humedad fuera de óptimo"))
                .fuera_de_rango([ "agronomo@yuca.com" ])
  end

  def solo_maximo
    AlertaMailer.with(alerta: alerta_de_ejemplo(severidad: "alerta", valor: 112_000, min: nil, max: 100_000,
                                                evento: "Luminosidad excesiva", variable: "Luminosidad", unidad: "lux", decimales: 0))
                .fuera_de_rango([ "agronomo@yuca.com" ])
  end

  private

  def alerta_de_ejemplo(severidad:, valor:, min:, max:, evento:, variable: "Humedad", unidad: "%", decimales: 1)
    finca    = Finca.new(id: 19, nombre: "Agrícola El Porvenir")
    cultivo  = Cultivo.new(id: 2, nombre: "Lote Sur", finca: finca)
    sensor   = Sensor.new(id: 3, codigo: "LS-SHT-01", nombre: "Sensor Humedad Sur", finca: finca, cultivo: cultivo)
    var      = Variable.new(id: 1, nombre: variable, unidad: unidad, decimales: decimales)
    ev       = VariableEvento.new(id: 8, nombre: evento, severidad: severidad, rango_min: min, rango_max: max,
                                  intervalo_minutos: 60, variable: var)
    lectura  = Lectura.new(id: 1, fecha: Date.new(2026, 9, 28), hora_registro: "14:00", valor: valor, sensor: sensor, variable: var)
    tipo     = min && valor < min ? "bajo" : "alto"

    Alerta.new(id: 1, lectura: lectura, variable_evento: ev, sensor: sensor, variable: var, finca: finca,
               tipo: tipo, severidad: severidad, valor: valor, rango_min: min, rango_max: max)
  end
end
