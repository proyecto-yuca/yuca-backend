module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        # Devise's verify_signed_out_user uses warden.user(run_callbacks: false)
        # which never runs the JWT strategy, so it always considers the user
        # "already signed out" in a stateless API. We skip it and handle it ourselves.
        skip_before_action :verify_signed_out_user, only: :destroy

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
          if request.headers["Authorization"].present?
            render json: { message: "Signed out successfully." }, status: :ok
          else
            render json: { message: "No active session." }, status: :unauthorized
          end
        end
      end
    end
  end
end
