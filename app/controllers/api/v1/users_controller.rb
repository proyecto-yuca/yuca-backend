module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_user!

      def show
        render json: { user: UserBlueprint.render_as_hash(current_user) }, status: :ok
      end

      def update
        if password_update?
          success = current_user.update_with_password(user_params)
        else
          success = current_user.update_without_password(user_params.except(:current_password, :password, :password_confirmation))
        end

        if success
          render json: { user: UserBlueprint.render_as_hash(current_user) }, status: :ok
        else
          render_errors(current_user.errors.full_messages)
        end
      end

      def destroy
        current_user.destroy!
        render json: { message: "User deleted successfully." }, status: :ok
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
      end

      def password_update?
        user_params[:password].present? || user_params[:password_confirmation].present?
      end
    end
  end
end
