module Api
  module V1
    class RolesController < BaseController
      before_action -> { require_permiso(:permisos, :ver) },      only: [ :index, :show ]
      before_action -> { require_permiso(:permisos, :crear) },    only: [ :create ]
      before_action -> { require_permiso(:permisos, :editar) },   only: [ :update ]
      before_action -> { require_permiso(:permisos, :eliminar) }, only: [ :destroy ]
      before_action :set_rol, only: [ :show, :update, :destroy ]

      # GET /api/v1/roles
      def index
        roles = Rol.includes(:permisos).order(:nombre)
        render json: roles.map { |r| serialize_rol(r) }
      end

      # GET /api/v1/roles/:id
      def show
        render json: serialize_rol(@rol)
      end

      # POST /api/v1/roles
      def create
        rol = Rol.new(rol_params)
        if rol.save
          render json: serialize_rol(rol), status: :created
        else
          render json: { errors: rol.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/roles/:id
      def update
        if @rol.update(rol_params)
          render json: serialize_rol(@rol)
        else
          render json: { errors: @rol.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/roles/:id
      def destroy
        if @rol.sistema?
          render json: { error: "No se puede eliminar un rol de sistema" }, status: :unprocessable_entity
          return
        end
        @rol.destroy!
        head :no_content
      end

      private

      def set_rol
        @rol = Rol.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Rol no encontrado" }, status: :not_found
      end

      def rol_params
        params.require(:rol).permit(:identificador, :nombre, :descripcion)
      end

      def serialize_rol(rol)
        {
          id:            rol.id.to_s,
          identificador: rol.identificador,
          nombre:        rol.nombre,
          descripcion:   rol.descripcion,
          sistema:       rol.sistema,
          usuarios:      rol.users.count,
          createdAt:     rol.created_at.iso8601,
          updatedAt:     rol.updated_at.iso8601
        }
      end
    end
  end
end
