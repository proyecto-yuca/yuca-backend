module Api
  module V1
    class SensoresController < BaseController
      before_action -> { require_permiso(:sensores, :ver) },      only: [ :index, :show ]
      before_action -> { require_permiso(:sensores, :crear) },    only: [ :create ]
      before_action -> { require_permiso(:sensores, :editar) },   only: [ :update, :toggle ]
      before_action -> { require_permiso(:sensores, :eliminar) }, only: [ :destroy ]
      before_action :set_finca
      before_action :set_sensor, only: [ :show, :update, :destroy, :toggle ]

      # GET /api/v1/fincas/:finca_id/sensores
      def index
        sensores = @finca.sensores.includes(:cultivo, :variables).order(created_at: :desc)
        render json: sensores.map { |s| serialize_sensor(s) }
      end

      # GET /api/v1/fincas/:finca_id/sensores/:id
      def show
        render json: serialize_sensor(@sensor)
      end

      # POST /api/v1/fincas/:finca_id/sensores
      def create
        sensor = @finca.sensores.build(sensor_params)
        sensor.variables = Variable.where(id: variable_ids) if params[:cultivo] || params.dig(:sensor, :variable_ids)

        if sensor.save
          sensor.variables = Variable.where(id: variable_ids)
          render json: serialize_sensor(sensor), status: :created
        else
          render json: { errors: sensor.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/fincas/:finca_id/sensores/:id
      def update
        if @sensor.update(sensor_params)
          @sensor.variables = Variable.where(id: variable_ids) if params.dig(:sensor, :variable_ids)
          render json: serialize_sensor(@sensor.reload)
        else
          render json: { errors: @sensor.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/fincas/:finca_id/sensores/:id/toggle
      def toggle
        @sensor.toggle_activo!
        render json: serialize_sensor(@sensor)
      end

      # DELETE /api/v1/fincas/:finca_id/sensores/:id
      def destroy
        @sensor.destroy!
        head :no_content
      end

      private

      def set_finca
        @finca = current_user.fincas.find(params[:finca_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Finca no encontrada" }, status: :not_found
      end

      def set_sensor
        @sensor = @finca.sensores.includes(:cultivo, :variables).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Sensor no encontrado" }, status: :not_found
      end

      def sensor_params
        params.require(:sensor).permit(:codigo, :nombre, :descripcion, :lat, :lng, :activo, :cultivo_id)
      end

      def variable_ids
        params.dig(:sensor, :variable_ids) || []
      end

      def serialize_sensor(sensor)
        {
          id:          sensor.id.to_s,
          codigo:      sensor.codigo,
          nombre:      sensor.nombre,
          descripcion: sensor.descripcion,
          posicion:    sensor.lat && sensor.lng ? { lat: sensor.lat.to_f, lng: sensor.lng.to_f } : nil,
          activo:      sensor.activo,
          cultivo:     sensor.cultivo ? { id: sensor.cultivo.id.to_s, nombre: sensor.cultivo.nombre } : nil,
          variables:   sensor.variables.map { |v| { id: v.id.to_s, nombre: v.nombre, unidad: v.unidad } },
          fincaId:     sensor.finca_id.to_s,
          createdAt:   sensor.created_at.iso8601,
          updatedAt:   sensor.updated_at.iso8601
        }
      end
    end
  end
end
