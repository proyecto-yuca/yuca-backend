module Api
  module V1
    module Iot
      class CredentialsController < Api::V1::BaseController
        before_action :set_finca

        # POST /api/v1/fincas/:finca_id/iot/credential
        def create
          credential = @finca.iot_credential || @finca.build_iot_credential
          raw_secret = "sec_#{SecureRandom.hex(24)}"

          credential.secret_id = raw_secret
          credential.active = true

          if credential.save
            render json: {
              fincaId: @finca.id.to_s,
              clientId: credential.client_id,
              secretId: raw_secret,
              active: credential.active
            }, status: :created
          else
            render_errors(credential.errors.full_messages)
          end
        end

        private

        def set_finca
          @finca = current_user.fincas.find(params[:finca_id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Finca no encontrada" }, status: :not_found
        end
      end
    end
  end
end
