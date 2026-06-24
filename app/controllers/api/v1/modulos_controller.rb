module Api
  module V1
    class ModulosController < BaseController
      # GET /api/v1/modulos
      def index
        modulos = Modulo.all
        render json: modulos.map { |m| serialize_modulo(m) }
      end

      private

      def serialize_modulo(modulo)
        {
          id:            modulo.id.to_s,
          identificador: modulo.identificador,
          nombre:        modulo.nombre,
          orden:         modulo.orden
        }
      end
    end
  end
end
