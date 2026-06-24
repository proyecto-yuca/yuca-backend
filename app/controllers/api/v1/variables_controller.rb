module Api
  module V1
    class VariablesController < BaseController
      before_action :set_variable, only: [ :show, :update, :destroy ]

      # GET /api/v1/variables
      def index
        variables = Variable.order(:nombre)
        render json: variables.map { |v| serialize_variable(v) }
      end

      # GET /api/v1/variables/:id
      def show
        render json: serialize_variable(@variable)
      end

      # POST /api/v1/variables
      def create
        variable = Variable.new(variable_params)
        if variable.save
          render json: serialize_variable(variable), status: :created
        else
          render json: { errors: variable.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/variables/:id
      def update
        if @variable.update(variable_params)
          render json: serialize_variable(@variable)
        else
          render json: { errors: @variable.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/variables/:id
      def destroy
        @variable.destroy!
        head :no_content
      end

      private

      def set_variable
        @variable = Variable.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Variable no encontrada" }, status: :not_found
      end

      def variable_params
        params.require(:variable).permit(:nombre, :unidad, :decimales, :descripcion)
      end

      def serialize_variable(variable)
        {
          id:          variable.id.to_s,
          nombre:      variable.nombre,
          unidad:      variable.unidad,
          decimales:   variable.decimales,
          descripcion: variable.descripcion,
          createdAt:   variable.created_at.iso8601,
          updatedAt:   variable.updated_at.iso8601
        }
      end
    end
  end
end
