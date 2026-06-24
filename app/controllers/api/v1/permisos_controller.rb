module Api
  module V1
    class PermisosController < BaseController
      before_action -> { require_permiso(:permisos, :ver) },    only: [ :index ]
      before_action -> { require_permiso(:permisos, :editar) }, only: [ :update ]
      before_action :set_rol

      # GET /api/v1/roles/:rol_id/permisos
      # Retorna la matriz completa de permisos del rol (todos los módulos)
      def index
        modulos  = Modulo.all
        permisos = @rol.permisos.index_by(&:modulo_id)

        render json: modulos.map { |m|
          p = permisos[m.id]
          {
            moduloId:      m.id.to_s,
            identificador: m.identificador,
            nombre:        m.nombre,
            orden:         m.orden,
            ver:           p&.ver      || false,
            crear:         p&.crear    || false,
            editar:        p&.editar   || false,
            eliminar:      p&.eliminar || false
          }
        }
      end

      # PUT /api/v1/roles/:rol_id/permisos
      # Reemplaza toda la matriz de permisos del rol de una vez
      def update
        unless params[:permisos].is_a?(Array)
          render json: { error: "Se espera un arreglo de permisos" }, status: :bad_request
          return
        end

        ActiveRecord::Base.transaction do
          params[:permisos].each do |p|
            modulo = Modulo.find(p[:modulo_id])
            permiso = @rol.permisos.find_or_initialize_by(modulo: modulo)
            permiso.update!(
              ver:      p[:ver]      || false,
              crear:    p[:crear]    || false,
              editar:   p[:editar]   || false,
              eliminar: p[:eliminar] || false
            )
          end
        end

        render json: { message: "Permisos actualizados correctamente" }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Módulo no encontrado" }, status: :not_found
      end

      private

      def set_rol
        @rol = Rol.find(params[:role_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Rol no encontrado" }, status: :not_found
      end
    end
  end
end
