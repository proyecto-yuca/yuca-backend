module Api
  module V1
    module Auth
      class PasswordsController < Devise::PasswordsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.errors.empty?
            render json: { message: success_message }, status: :ok
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
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
