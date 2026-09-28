module Api
  module V1
    class LecturasController < BaseController
      before_action -> { require_permiso(:mediciones, :ver) },   only: [ :index ]
      before_action -> { require_permiso(:mediciones, :crear) }, only: [ :create ]
      before_action :set_finca
      before_action :set_sensor

      # GET /api/v1/fincas/:finca_id/sensores/:sensor_id/lecturas
      def index
        lecturas = @sensor.lecturas.includes(variable: :eventos).cronologico_desc
        lecturas = lecturas.por_variable(params[:variable_id])
        lecturas = lecturas.fuera_de_rango if params[:estado] == "fuera"

        if params[:fecha_desde].present? && params[:fecha_hasta].present?
          lecturas = lecturas.en_rango(params[:fecha_desde], params[:fecha_hasta])
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
          totalPages: pagy.pages
        }
      end

      # POST /api/v1/fincas/:finca_id/sensores/:sensor_id/lecturas
      def create
        lectura = @sensor.lecturas.build(lectura_params)

        if lectura.save
          render json: serialize_lectura(lectura), status: :created
        else
          render json: { errors: lectura.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_finca
        @finca = finca_scope.find(params[:finca_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Finca no encontrada" }, status: :not_found
      end

      def set_sensor
        @sensor = @finca.sensores.find(params[:sensor_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Sensor no encontrado" }, status: :not_found
      end

      def lectura_params
        params.require(:lectura).permit(:variable_id, :fecha, :hora_registro, :valor)
      end

      def serialize_lectura(lectura)
        {
          id:           lectura.id.to_s,
          fecha:        lectura.fecha.to_s,
          horaRegistro: lectura.hora_registro,
          valor:        lectura.valor.to_f,
          sensor:       { id: @sensor.id.to_s, codigo: @sensor.codigo, nombre: @sensor.nombre },
          cultivo:      @sensor.cultivo ? { id: @sensor.cultivo.id.to_s, nombre: @sensor.cultivo.nombre } : nil,
          variable:     serialize_variable_ref(lectura.variable),
          estado:       lectura.variable.estado_para(lectura.valor),
          eventos:      lectura.variable.eventos_disparados(lectura.valor).map do |evento, tipo|
            { id: evento.id.to_s, nombre: evento.nombre, severidad: evento.severidad, tipo: tipo }
          end
        }
      end

      # Incluye los rangos activos para que el frontend dibuje las bandas del gráfico.
      def serialize_variable_ref(variable)
        {
          id:      variable.id.to_s,
          nombre:  variable.nombre,
          unidad:  variable.unidad,
          rangos:  variable.eventos.select(&:activo?).map do |e|
            { eventoId: e.id.to_s, nombre: e.nombre, severidad: e.severidad, min: e.rango_min&.to_f, max: e.rango_max&.to_f }
          end
        }
      end
    end
  end
end
