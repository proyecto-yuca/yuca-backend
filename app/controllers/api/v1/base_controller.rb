module Api
  module V1
    class BaseController < ApplicationController
      include PermissionGuard

      before_action :authenticate_user!

      private

      def render_errors(errors, status: :unprocessable_entity)
        render json: { errors: Array(errors) }, status: status
      end
    end
  end
end
