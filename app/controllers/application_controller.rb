class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers

  rescue_from ActiveRecord::RecordNotFound do |_e|
    render json: { error: "Recurso no encontrado" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :bad_request
  end
end
