module Api
  module V1
    class LecturasSensorController < BaseController
      before_action :set_finca

      # GET /api/v1/fincas/:finca_id/lecturas
      def index
        lecturas = @finca.lecturas_sensor.cronologico_desc

        if params[:fecha_desde].present? && params[:fecha_hasta].present?
          lecturas = lecturas.en_rango(params[:fecha_desde], params[:fecha_hasta])
        end

        if params[:estado].present? && params[:estado] != "todos"
          lecturas = lecturas.where(estado: params[:estado])
        end

        page_size = [ [ params.fetch(:page_size, 10).to_i, 1 ].max, 100 ].min
        page      = [ params.fetch(:page, 1).to_i, 1 ].max
        pagy      = Pagy::Offset.new(count: lecturas.count, page: page, limit: page_size)
        records   = pagy.records(lecturas)

        render json: {
          data:       records.map { |l| serialize_lectura(l) },
          total:      pagy.count,
          page:       pagy.page,
          pageSize:   pagy.limit,
          totalPages: pagy.pages,
          resumen:    build_resumen(@finca)
        }
      end

      # GET /api/v1/fincas/:finca_id/lecturas/recientes
      def recientes
        lecturas = @finca.lecturas_sensor.recientes.cronologico_desc
        render json: lecturas.map { |l| serialize_lectura(l) }
      end

      # POST /api/v1/fincas/:finca_id/lecturas
      def create
        lectura = @finca.lecturas_sensor.build(lectura_params)

        if lectura.save
          render json: serialize_lectura(lectura), status: :created
        else
          render json: { errors: lectura.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_finca
        @finca = current_user.fincas.find(params[:finca_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Finca no encontrada" }, status: :not_found
      end

      def lectura_params
        params.require(:lectura).permit(:sensor_id, :fecha, :hora_registro,
                                        :humedad, :temperatura)
              .transform_keys { |k| k.to_s.underscore }
      end

      def build_resumen(finca)
        todas = finca.lecturas_sensor
        return empty_resumen if todas.empty?

        ultima = todas.order(fecha: :desc, hora_registro: :desc).first

        {
          totalLecturas:       todas.count,
          humedadPromedio:     todas.average(:humedad).to_f.round(1),
          temperaturaPromedio: todas.average(:temperatura).to_f.round(1),
          humedadMin:          todas.minimum(:humedad).to_f,
          humedadMax:          todas.maximum(:humedad).to_f,
          temperaturaMin:      todas.minimum(:temperatura).to_f,
          temperaturaMax:      todas.maximum(:temperatura).to_f,
          alertas:             todas.where(estado: "alerta").count,
          criticos:            todas.where(estado: "critico").count,
          ultimaLectura:       ultima ? "#{ultima.fecha} #{ultima.hora_registro}" : nil
        }
      end

      def empty_resumen
        {
          totalLecturas: 0, humedadPromedio: 0, temperaturaPromedio: 0,
          humedadMin: 0, humedadMax: 0, temperaturaMin: 0, temperaturaMax: 0,
          alertas: 0, criticos: 0, ultimaLectura: nil
        }
      end

      def serialize_lectura(lectura)
        {
          id:           lectura.id.to_s,
          fincaId:      lectura.finca_id.to_s,
          fecha:        lectura.fecha.to_s,
          horaRegistro: lectura.hora_registro,
          sensorId:     lectura.sensor_id,
          humedad:      lectura.humedad.to_f,
          temperatura:  lectura.temperatura.to_f,
          estado:       lectura.estado
        }
      end
    end
  end
end
