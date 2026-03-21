module Api
  module V1
    class BaseController < ApplicationController
      private

      def render_errors(errors, status: :unprocessable_entity)
        render json: { errors: Array(errors) }, status: status
      end
    end
  end
end
