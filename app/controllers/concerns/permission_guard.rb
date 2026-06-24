module PermissionGuard
  extend ActiveSupport::Concern

  def require_permiso(modulo_identificador, operacion)
    rol = current_user&.rol

    unless rol
      render json: { error: "Usuario sin rol asignado" }, status: :forbidden
      return
    end

    permiso = permisos_cache[modulo_identificador.to_s]

    unless permiso&.public_send(operacion)
      render json: {
        error:     "No tienes permiso para realizar esta acción",
        modulo:    modulo_identificador,
        operacion: operacion
      }, status: :forbidden
    end
  end

  def permisos_del_usuario(user)
    rol = user.rol
    return {} unless rol

    modulos = Modulo.all
    permisos = rol.permisos.index_by(&:modulo_id)

    modulos.each_with_object({}) do |modulo, hash|
      p = permisos[modulo.id]
      hash[modulo.identificador] = {
        ver:      p&.ver      || false,
        crear:    p&.crear    || false,
        editar:   p&.editar   || false,
        eliminar: p&.eliminar || false
      }
    end
  end

  private

  def permisos_cache
    @_permisos_cache ||= begin
      rol = current_user&.rol
      return {} unless rol
      rol.permisos.includes(:modulo).index_by { |p| p.modulo.identificador }
    end
  end
end
