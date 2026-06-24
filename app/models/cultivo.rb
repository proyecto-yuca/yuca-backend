class Cultivo < ApplicationRecord
  belongs_to :finca
  has_many :sensores, class_name: "Sensor", dependent: :nullify

  validates :nombre, presence: true, length: { maximum: 255 }
  validate :puntos_ubicacion_validos

  private

  def puntos_ubicacion_validos
    puntos = puntos_ubicacion || []

    unless puntos.is_a?(Array)
      errors.add(:puntos_ubicacion, "debe ser un arreglo")
      return
    end

    if puntos.size > 4
      errors.add(:puntos_ubicacion, "no puede tener más de 4 puntos")
      return
    end

    puntos.each_with_index do |punto, i|
      unless punto.is_a?(Hash) &&
             punto["lat"].present? && punto["lng"].present? &&
             punto["lat"].to_s.match?(/\A-?\d+(\.\d+)?\z/) &&
             punto["lng"].to_s.match?(/\A-?\d+(\.\d+)?\z/)
        errors.add(:puntos_ubicacion, "punto #{i + 1} debe tener lat y lng numéricos")
      end
    end
  end
end
