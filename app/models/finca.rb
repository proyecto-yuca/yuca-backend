class Finca < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many :cultivos, dependent: :destroy
  has_many :sensores, class_name: "Sensor", dependent: :destroy
  has_many :lecturas_sensor, class_name: "LecturaSensor", dependent: :destroy
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

  def set_fecha_registro
    self.fecha_registro ||= Date.today
  end
end
