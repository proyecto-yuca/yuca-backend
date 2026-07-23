module Api
  module V1
    module Iot
      class LecturasSyncController < BaseController
        # POST /api/v1/iot/lecturas_sensor/sync
        def create
          lecturas = params.require(:lecturas)
          raise ActionController::BadRequest, "lecturas debe ser un arreglo" unless lecturas.is_a?(Array)

          records = lecturas.map.with_index do |raw_lectura, idx|
            [idx, normalize_lectura(raw_lectura)]
          end

          resultado = {
            received: records.size,
            created: 0,
            duplicated: 0,
            failed: 0
          }
          errors = []

          records.each do |idx, attrs|
            sensor   = @finca.sensores.find_by(codigo: attrs[:sensor_codigo])
            variable = Variable.find_by(nombre: attrs[:variable_nombre])

            if sensor.nil? || variable.nil?
              resultado[:failed] += 1
              errors << { index: idx, messages: [ sensor.nil? ? "sensor_codigo desconocido" : "variable_nombre desconocido" ] }
              next
            end

            lectura = sensor.lecturas.find_or_initialize_by(
              variable:      variable,
              fecha:         attrs[:fecha],
              hora_registro: attrs[:hora_registro]
            )

            if lectura.persisted?
              resultado[:duplicated] += 1
              next
            end

            lectura.valor = attrs[:valor]

            if lectura.save
              resultado[:created] += 1
            else
              resultado[:failed] += 1
              errors << { index: idx, messages: lectura.errors.full_messages }
            end
          end

          @iot_credential.update_column(:last_synced_at, Time.current)

          status = resultado[:failed].zero? ? :created : :multi_status
          render json: {
            finca_id: @finca.id,
            sync_at: Time.current,
            stats: resultado,
            errors: errors
          }, status: status
        end

        private

        def normalize_lectura(raw_lectura)
          lectura_params = if raw_lectura.is_a?(ActionController::Parameters)
            raw_lectura
          else
            ActionController::Parameters.new(raw_lectura)
          end

          lectura_params.permit(
            :sensor_codigo, :variable_nombre, :fecha, :hora_registro, :valor
          ).to_h.symbolize_keys
        end
      end
    end
  end
end
