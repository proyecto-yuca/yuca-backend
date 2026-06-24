module Api
  module V1
    class UsuariosController < BaseController
      before_action -> { require_permiso(:usuarios, :ver) },      only: [ :index, :show ]
      before_action -> { require_permiso(:usuarios, :crear) },    only: [ :create ]
      before_action -> { require_permiso(:usuarios, :editar) },   only: [ :update ]
      before_action -> { require_permiso(:usuarios, :eliminar) }, only: [ :destroy ]
      before_action -> { require_permiso(:usuarios, :editar) }, only: [ :cambiar_password, :toggle_estado ]
      before_action :set_usuario, only: [ :show, :update, :destroy, :cambiar_password, :toggle_estado ]

      # GET /api/v1/usuarios
      def index
        usuarios = User.includes(:rol).order(created_at: :desc)
        render json: usuarios.map { |u| serialize_usuario(u) }
      end

      # GET /api/v1/usuarios/:id
      def show
        render json: serialize_usuario(@usuario)
      end

      # POST /api/v1/usuarios
      def create
        usuario = User.new(create_params)
        if usuario.save
          render json: serialize_usuario(usuario), status: :created
        else
          render json: { errors: usuario.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/usuarios/:id
      def update
        if update_params[:password].present?
          success = @usuario.update(update_params)
        else
          success = @usuario.update(update_params.except(:password, :password_confirmation))
        end

        if success
          render json: serialize_usuario(@usuario)
        else
          render json: { errors: @usuario.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/usuarios/:id/cambiar_password
      def cambiar_password
        password = params.dig(:usuario, :password)
        confirmation = params.dig(:usuario, :password_confirmation)

        if password.blank?
          render json: { error: "La contraseña no puede estar vacía" }, status: :unprocessable_entity
          return
        end

        if password != confirmation
          render json: { error: "La confirmación de contraseña no coincide" }, status: :unprocessable_entity
          return
        end

        if @usuario.update(password: password, password_confirmation: confirmation)
          render json: { message: "Contraseña actualizada correctamente" }
        else
          render json: { errors: @usuario.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/usuarios/:id/toggle_estado
      def toggle_estado
        if @usuario == current_user
          render json: { error: "No puedes cambiar el estado de tu propio usuario" }, status: :unprocessable_entity
          return
        end
        @usuario.toggle_estado!
        render json: serialize_usuario(@usuario)
      end

      # DELETE /api/v1/usuarios/:id
      def destroy
        if @usuario == current_user
          render json: { error: "No puedes eliminar tu propio usuario" }, status: :unprocessable_entity
          return
        end
        @usuario.destroy!
        head :no_content
      end

      private

      def set_usuario
        @usuario = User.includes(:rol).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Usuario no encontrado" }, status: :not_found
      end

      def create_params
        params.require(:usuario).permit(:name, :email, :password, :password_confirmation, :rol_id)
      end

      def update_params
        params.require(:usuario).permit(:name, :email, :password, :password_confirmation, :rol_id)
      end

      def serialize_usuario(usuario)
        {
          id:        usuario.id.to_s,
          name:      usuario.name,
          email:     usuario.email,
          estado:    usuario.estado,
          rol:       usuario.rol ? { id: usuario.rol.id.to_s, identificador: usuario.rol.identificador, nombre: usuario.rol.nombre } : nil,
          createdAt: usuario.created_at.iso8601,
          updatedAt: usuario.updated_at.iso8601
        }
      end
    end
  end
end
