module Alertas
  # Crea una Alerta por cada evento activo que la lectura incumple y encola el
  # correo, respetando el intervalo anti-spam por sensor + evento.
  class EvaluarLectura
    def self.call(lectura)
      new(lectura).call
    end

    def initialize(lectura)
      @lectura = lectura
      @sensor  = lectura.sensor
    end

    def call
      @lectura.variable.eventos_disparados(@lectura.valor).map do |evento, tipo|
        alerta = crear_alerta(evento, tipo)
        programar_correo(alerta, evento)
        alerta
      end
    end

    private

    def crear_alerta(evento, tipo)
      Alerta.create!(
        lectura:         @lectura,
        variable_evento: evento,
        sensor:          @sensor,
        variable:        @lectura.variable,
        finca_id:        @sensor.finca_id,
        tipo:            tipo,
        severidad:       evento.severidad,
        valor:           @lectura.valor,
        rango_min:       evento.rango_min,
        rango_max:       evento.rango_max
      )
    end

    def programar_correo(alerta, evento)
      unless evento.notificar_email?
        return alerta.update!(notificacion_omitida: true, motivo_omision: "sin_correo")
      end

      desde = evento.intervalo_minutos.minutes.ago
      if Alerta.notificada_desde?(@sensor.id, evento.id, desde, excepto_id: alerta.id)
        alerta.update!(notificacion_omitida: true, motivo_omision: "intervalo")
      else
        NotificarAlertaJob.perform_later(alerta.id)
      end
    end
  end
end
