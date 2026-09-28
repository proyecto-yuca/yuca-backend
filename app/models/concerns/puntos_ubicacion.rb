# Puntos {lat, lng} (máx. 4) que delimitan un área en el mapa.
# La geometría replica yuca-frontend/src/lib/mapGeometry.ts para que
# backend y frontend den el mismo resultado.
module PuntosUbicacion
  extend ActiveSupport::Concern

  MAX_PUNTOS = 4
  NUMERO_REGEX = /\A-?\d+(\.\d+)?\z/

  included do
    validate :puntos_ubicacion_validos
  end

  # Puntos como floats, ordenados angularmente alrededor del centroide
  # para evitar bordes autointersectados. Vacío si hay menos de 3 puntos.
  def poligono
    puntos = (puntos_ubicacion || []).map { |p| { lat: p["lat"].to_f, lng: p["lng"].to_f } }
    return [] if puntos.size < 3

    centro_lat = puntos.sum { |p| p[:lat] } / puntos.size
    centro_lng = puntos.sum { |p| p[:lng] } / puntos.size
    puntos.sort_by { |p| Math.atan2(p[:lat] - centro_lat, p[:lng] - centro_lng) }
  end

  # Ray casting sobre el polígono ordenado.
  def contiene_punto?(lat, lng)
    vertices = poligono
    return false if vertices.empty?

    y = lat.to_f
    x = lng.to_f
    dentro = false
    j = vertices.size - 1
    vertices.each_with_index do |vi, i|
      vj = vertices[j]
      if (vi[:lat] > y) != (vj[:lat] > y) &&
         x < (vj[:lng] - vi[:lng]) * (y - vi[:lat]) / (vj[:lat] - vi[:lat]) + vi[:lng]
        dentro = !dentro
      end
      j = i
    end
    dentro
  end

  private

  def puntos_ubicacion_validos
    puntos = puntos_ubicacion || []

    unless puntos.is_a?(Array)
      errors.add(:puntos_ubicacion, "debe ser un arreglo")
      return
    end

    if puntos.size > MAX_PUNTOS
      errors.add(:puntos_ubicacion, "no puede tener más de #{MAX_PUNTOS} puntos")
      return
    end

    puntos.each_with_index do |punto, i|
      unless punto_valido?(punto)
        errors.add(:puntos_ubicacion, "punto #{i + 1} debe tener lat y lng numéricos")
      end
    end
  end

  def punto_valido?(punto)
    punto.is_a?(Hash) &&
      punto["lat"].present? && punto["lng"].present? &&
      punto["lat"].to_s.match?(NUMERO_REGEX) &&
      punto["lng"].to_s.match?(NUMERO_REGEX)
  end

  def puntos_ubicacion_con_formato_valido?
    puntos = puntos_ubicacion
    puntos.is_a?(Array) && puntos.all? { |p| punto_valido?(p) }
  end
end
