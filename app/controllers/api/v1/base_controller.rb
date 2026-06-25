module Api
  module V1
    class BaseController < ApplicationController
      include PermissionGuard

      before_action :authenticate_user!

      private

      # Returns a Finca scope visible to the current user.
      # Admin/consultant see all fincas; owners/users see only their own.
      # Admin/consultant can also filter by ?user_id=X.
      def finca_scope
        rol = current_user.rol&.identificador
        if rol.in?(%w[admin consultant])
          scope = Finca.all
          scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
          scope
        else
          current_user.fincas
        end
      end

      def render_errors(errors, status: :unprocessable_entity)
        render json: { errors: Array(errors) }, status: status
      end
    end
  end
end
