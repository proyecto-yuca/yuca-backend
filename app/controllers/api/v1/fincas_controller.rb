module Api
  module V1
    class FincasController < BaseController
      before_action :set_finca, only: [ :show, :update, :estado ]

      # GET /api/v1/fincas
      def index
        fincas = current_user.fincas

        fincas = fincas.buscar(params[:search]) if params[:search].present?

        if params[:estado].present? && params[:estado] != "todos"
          fincas = fincas.where(estado: params[:estado])
        end

        fincas = fincas.order(created_at: :desc)

        page_size = [ [ params.fetch(:page_size, 6).to_i, 1 ].max, 100 ].min
        page      = [ params.fetch(:page, 1).to_i, 1 ].max
        pagy      = Pagy::Offset.new(count: fincas.count, page: page, limit: page_size)
        records   = pagy.records(fincas)

        render json: {
          data:       records.map { |f| serialize_finca(f) },
          total:      pagy.count,
          page:       pagy.page,
          pageSize:   pagy.limit,
          totalPages: pagy.pages
        }
      end

      # GET /api/v1/fincas/:id
      def show
        render json: serialize_finca(@finca)
      end

      # POST /api/v1/fincas
      def create
        finca = current_user.fincas.build(finca_params)
        if finca.save
          render json: serialize_finca(finca), status: :created
        else
          render json: { errors: finca.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/fincas/:id
      def update
        if @finca.update(finca_params)
          render json: serialize_finca(@finca)
        else
          render json: { errors: @finca.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/fincas/:id/estado
      def estado
        @finca.toggle_estado!
        render json: serialize_finca(@finca)
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors }, status: :unprocessable_entity
      end

      private

      def set_finca
        @finca = current_user.fincas.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Finca no encontrada" }, status: :not_found
      end

      def finca_params
        params.require(:finca).permit(
          :nombre, :descripcion, :area,
          ubicacion: [ :departamento, :municipio, :vereda, :coordenadas, :direccion ],
          dueno:     [ :nombre, :tipoDocumento, :numeroDocumento, :email, :telefono, :direccion ]
        ).then { |p| flatten_nested_params(p) }
      end

      def flatten_nested_params(p)
        result = p.except(:ubicacion, :dueno).to_h

        if p[:ubicacion]
          result[:departamento]        = p[:ubicacion][:departamento]
          result[:municipio]           = p[:ubicacion][:municipio]
          result[:vereda]              = p[:ubicacion][:vereda]
          result[:coordenadas]         = p[:ubicacion][:coordenadas]
          result[:direccion_ubicacion] = p[:ubicacion][:direccion]
        end

        if p[:dueno]
          result[:dueno_nombre]           = p[:dueno][:nombre]
          result[:dueno_tipo_documento]   = p[:dueno][:tipoDocumento]
          result[:dueno_numero_documento] = p[:dueno][:numeroDocumento]
          result[:dueno_email]            = p[:dueno][:email]
          result[:dueno_telefono]         = p[:dueno][:telefono]
          result[:dueno_direccion]        = p[:dueno][:direccion]
        end

        result
      end

      def serialize_finca(finca)
        {
          id:          finca.id.to_s,
          nombre:      finca.nombre,
          descripcion: finca.descripcion,
          area:        finca.area.to_f,
          ubicacion: {
            departamento: finca.departamento,
            municipio:    finca.municipio,
            vereda:       finca.vereda,
            coordenadas:  finca.coordenadas,
            direccion:    finca.direccion_ubicacion
          },
          dueno: {
            nombre:          finca.dueno_nombre,
            tipoDocumento:   finca.dueno_tipo_documento,
            numeroDocumento: finca.dueno_numero_documento,
            email:           finca.dueno_email,
            telefono:        finca.dueno_telefono,
            direccion:       finca.dueno_direccion
          },
          estado:        finca.estado,
          fechaRegistro: finca.fecha_registro.to_s
        }
      end
    end
  end
end
