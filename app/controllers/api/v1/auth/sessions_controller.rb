module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(current_user, _opts = {})
          render json: {
            user: UserBlueprint.render_as_hash(current_user),
            token: request.env["warden-jwt_auth.token"]
          }, status: :ok
        end

        def respond_to_on_destroy
          if current_user
            render json: { message: "Signed out successfully." }, status: :ok
          else
            render json: { message: "Session not found." }, status: :unauthorized
          end
        end

        def current_user
          @current_user ||= User.find_by(id: jwt_payload_sub)
        end

        def jwt_payload_sub
          payload = request.env["warden-jwt_auth.payload"]
          payload && payload["sub"]
        end
      end
    end
  end
end
