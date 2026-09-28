module Api
  module V1
    class AlertasController < BaseController
      before_action -> { require_permiso(:mediciones, :ver) }
      before_action :set_finca

      # GET /api/v1/fincas/:finca_id/alertas
      def index
        alertas = @finca.alertas
          .includes(:variable, :variable_evento, :lectura, sensor: :cultivo)
          .recientes

        alertas = alertas.where(sensor_id: params[:sensor_id])             if params[:sensor_id].present?
        alertas = alertas.where(variable_id: params[:variable_id])         if params[:variable_id].present?
        alertas = alertas.where(variable_evento_id: params[:evento_id])    if params[:evento_id].present?
        alertas = alertas.where(severidad: params[:severidad])             if params[:severidad].present?

        if params[:fecha_desde].present? && params[:fecha_hasta].present?
          alertas = alertas.joins(:lectura).where(lecturas: { fecha: params[:fecha_desde]..params[:fecha_hasta] })
        end

        page_size = [ [ params.fetch(:page_size, 10).to_i, 1 ].max, 100 ].min
        page      = [ params.fetch(:page, 1).to_i, 1 ].max
        pagy      = Pagy::Offset.new(count: alertas.count, page: page, limit: page_size)
        records   = pagy.records(alertas)

        render json: {
          data:       records.map { |a| serialize_alerta(a) },
          total:      pagy.count,
          page:       pagy.page,
          pageSize:   pagy.limit,
          totalPages: pagy.pages
        }
      end

      private

      def set_finca
        @finca = finca_scope.find(params[:finca_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Finca no encontrada" }, status: :not_found
      end

      def serialize_alerta(alerta)
        sensor = alerta.sensor
        {
          id:           alerta.id.to_s,
          tipo:         alerta.tipo,
          severidad:    alerta.severidad,
          valor:        alerta.valor.to_f,
          rango:        { min: alerta.rango_min&.to_f, max: alerta.rango_max&.to_f },
          evento:       { id: alerta.variable_evento_id.to_s, nombre: alerta.variable_evento.nombre },
          variable:     { id: alerta.variable_id.to_s, nombre: alerta.variable.nombre, unidad: alerta.variable.unidad },
          sensor:       { id: sensor.id.to_s, codigo: sensor.codigo, nombre: sensor.nombre },
          cultivo:      sensor.cultivo ? { id: sensor.cultivo.id.to_s, nombre: sensor.cultivo.nombre } : nil,
          fecha:        alerta.lectura.fecha.to_s,
          horaRegistro: alerta.lectura.hora_registro,
          envio: {
            enviadoAt:     alerta.email_enviado_at&.iso8601,
            emails:        alerta.emails_enviados,
            omitido:       alerta.notificacion_omitida,
            motivoOmision: alerta.motivo_omision,
            error:         alerta.error_envio
          },
          createdAt:    alerta.created_at.iso8601
        }
      end
    end
  end
end
