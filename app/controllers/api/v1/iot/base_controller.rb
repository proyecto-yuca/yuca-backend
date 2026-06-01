module Api
  module V1
    module Iot
      class BaseController < ApplicationController
        before_action :authenticate_iot_client!

        private

        def authenticate_iot_client!
          client_id = request.headers["X-Client-Id"].presence || params[:client_id]
          secret_id = request.headers["X-Secret-Id"].presence || params[:secret_id]

          if client_id.blank? || secret_id.blank?
            render json: { error: "client_id y secret_id son requeridos" }, status: :unauthorized
            return
          end

          @iot_credential = IotCredential.active.includes(:finca).find_by(client_id: client_id)

          unless @iot_credential&.authenticate_secret_id(secret_id)
            render json: { error: "Credenciales IoT invalidas" }, status: :unauthorized
            return
          end

          @finca = @iot_credential.finca
        end

        def render_iot_errors(errors, status: :unprocessable_entity)
          render json: { errors: Array(errors) }, status: status
        end
      end
    end
  end
end
