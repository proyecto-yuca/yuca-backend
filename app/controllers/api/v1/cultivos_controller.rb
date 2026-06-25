module Api
  module V1
    class CultivosController < BaseController
      before_action -> { require_permiso(:cultivos, :ver) },      only: [ :index, :show ]
      before_action -> { require_permiso(:cultivos, :crear) },    only: [ :create ]
      before_action -> { require_permiso(:cultivos, :editar) },   only: [ :update ]
      before_action -> { require_permiso(:cultivos, :eliminar) }, only: [ :destroy ]
      before_action :set_finca
      before_action :set_cultivo, only: [ :show, :update, :destroy ]

      # GET /api/v1/fincas/:finca_id/cultivos
      def index
        cultivos = @finca.cultivos.order(created_at: :desc)
        render json: cultivos.map { |c| serialize_cultivo(c) }
      end

      # GET /api/v1/fincas/:finca_id/cultivos/:id
      def show
        render json: serialize_cultivo(@cultivo)
      end

      # POST /api/v1/fincas/:finca_id/cultivos
      def create
        cultivo = @finca.cultivos.build(cultivo_params)
        if cultivo.save
          render json: serialize_cultivo(cultivo), status: :created
        else
          render json: { errors: cultivo.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/fincas/:finca_id/cultivos/:id
      def update
        if @cultivo.update(cultivo_params)
          render json: serialize_cultivo(@cultivo)
        else
          render json: { errors: @cultivo.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/fincas/:finca_id/cultivos/:id
      def destroy
        @cultivo.destroy!
        head :no_content
      end

      private

      def set_finca
        @finca = finca_scope.find(params[:finca_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Finca no encontrada" }, status: :not_found
      end

      def set_cultivo
        @cultivo = @finca.cultivos.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Cultivo no encontrado" }, status: :not_found
      end

      def cultivo_params
        params.require(:cultivo).permit(
          :nombre, :descripcion,
          puntos_ubicacion: [ :lat, :lng ]
        )
      end

      def serialize_cultivo(cultivo)
        {
          id:               cultivo.id.to_s,
          nombre:           cultivo.nombre,
          descripcion:      cultivo.descripcion,
          puntosUbicacion:  (cultivo.puntos_ubicacion || []).map do |p|
            { lat: p["lat"].to_f, lng: p["lng"].to_f }
          end,
          fincaId:          cultivo.finca_id.to_s,
          createdAt:        cultivo.created_at.iso8601,
          updatedAt:        cultivo.updated_at.iso8601
        }
      end
    end
  end
end
