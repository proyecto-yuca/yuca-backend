module Api
  module V1
    module Auth
      class PasswordsController < Devise::PasswordsController
        respond_to :json

        private

        def resource_params
          params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
        end

        def respond_with(resource, _opts = {})
          if resource.respond_to?(:errors) && resource.errors.any?
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          else
            render json: { message: success_message }, status: :ok
          end
        end

        def success_message
          if action_name == "create"
            "Reset password instructions sent if the email exists."
          else
            "Password updated successfully."
          end
        end
      end
    end
  end
end
