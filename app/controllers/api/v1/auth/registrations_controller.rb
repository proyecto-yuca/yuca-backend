module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def sign_up_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation)
        end

        def account_update_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
        end

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              user: UserBlueprint.render_as_hash(resource),
              token: request.env["warden-jwt_auth.token"]
            }, status: :created
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
