class Cultivo < ApplicationRecord
  include PuntosUbicacion

  belongs_to :finca
  has_many :sensores, class_name: "Sensor", dependent: :nullify
  has_many :lecturas, through: :sensores

  validates :nombre, presence: true, length: { maximum: 255 }
  validate :dentro_de_la_finca

  private

  def dentro_de_la_finca
    return if finca.nil? || finca.poligono.empty?
    return unless puntos_ubicacion_con_formato_valido?

    puntos_ubicacion.each_with_index do |punto, i|
      unless finca.contiene_punto?(punto["lat"], punto["lng"])
        errors.add(:puntos_ubicacion, "punto #{i + 1} está fuera del área de la finca")
      end
    end
  end
end
