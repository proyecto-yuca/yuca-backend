class LecturaSensor < ApplicationRecord
  self.table_name = "lecturas_sensor"

  belongs_to :finca

  ESTADOS = %w[normal alerta critico].freeze

  validates :sensor_id, :fecha, :hora_registro, presence: true
  validates :humedad, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :temperatura, numericality: true
  validates :estado, inclusion: { in: ESTADOS }

  before_validation :calcular_estado

  scope :en_rango,        ->(desde, hasta) { where(fecha: desde..hasta) }
  scope :por_estado,      ->(est) { where(estado: est) unless est == "todos" }
  scope :recientes,       -> { where(fecha: Date.today) }
  scope :cronologico_desc, -> { order(fecha: :desc, hora_registro: :desc) }

  private

  def calcular_estado
    return unless humedad && temperatura

    hum_critico  = humedad < 30  || humedad > 90
    temp_critico = temperatura < 5  || temperatura > 38
    hum_alerta   = humedad < 40  || humedad > 80
    temp_alerta  = temperatura < 10 || temperatura > 33

    self.estado = if hum_critico || temp_critico
      "critico"
    elsif hum_alerta || temp_alerta
      "alerta"
    else
      "normal"
    end
  end
end
