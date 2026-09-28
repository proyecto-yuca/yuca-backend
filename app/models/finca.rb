class Finca < ApplicationRecord
  include PgSearch::Model
  include PuntosUbicacion

  belongs_to :user
  has_many :cultivos, dependent: :destroy
  has_many :sensores, class_name: "Sensor", dependent: :destroy
  has_many :lecturas, through: :sensores
  has_many :alertas, dependent: :delete_all
  has_one :iot_credential, dependent: :destroy

  ESTADOS = %w[activo inactivo].freeze
  TIPOS_DOCUMENTO = %w[CC NIT CE PP].freeze

  pg_search_scope :buscar,
    against: {
      nombre:       "A",
      municipio:    "B",
      departamento: "B",
      dueno_nombre: "C"
    },
    using: {
      tsearch: { prefix: true, dictionary: "spanish" }
    }

  validates :nombre, presence: true, length: { maximum: 255 }
  validates :area, presence: true, numericality: { greater_than: 0 }
  validates :estado, inclusion: { in: ESTADOS }
  validates :departamento, :municipio, presence: true
  validates :dueno_nombre, :dueno_numero_documento,
            :dueno_email, :dueno_telefono, presence: true
  validates :dueno_tipo_documento, inclusion: { in: TIPOS_DOCUMENTO }
  validates :dueno_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :cultivos_dentro_del_poligono, if: :puntos_ubicacion_changed?

  before_create :set_fecha_registro

  scope :activas,   -> { where(estado: "activo") }
  scope :inactivas, -> { where(estado: "inactivo") }

  def toggle_estado!
    new_estado = activo? ? "inactivo" : "activo"
    update!(estado: new_estado)
  end

  def activo?
    estado == "activo"
  end

  private

  def cultivos_dentro_del_poligono
    return if new_record? || poligono.empty?
    return unless puntos_ubicacion_con_formato_valido?

    cultivos.each do |cultivo|
      fuera = (cultivo.puntos_ubicacion || []).any? { |p| !contiene_punto?(p["lat"], p["lng"]) }
      errors.add(:puntos_ubicacion, "el cultivo #{cultivo.nombre} quedaría fuera del área de la finca") if fuera
    end
  end

  def set_fecha_registro
    self.fecha_registro ||= Date.today
  end
end
