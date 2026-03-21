module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def sign_in_params
          params.require(:user).permit(:email, :password)
        end

        def respond_with(resource, _opts = {})
          render json: {
            user: UserBlueprint.render_as_hash(resource),
            token: request.env["warden-jwt_auth.token"]
          }, status: :ok
        end

        def respond_to_on_destroy(*_args)
          payload = request.env["warden-jwt_auth.payload"]
          if payload.present?
            render json: { message: "Signed out successfully." }, status: :ok
          else
            render json: { message: "Session not found." }, status: :unauthorized
          end
        end

      end
    end
  end
end
