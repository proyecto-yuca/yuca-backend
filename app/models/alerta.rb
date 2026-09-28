# Registro de una lectura que salió del rango de un evento, y del correo enviado por ella.
class Alerta < ApplicationRecord
  TIPOS = %w[bajo alto].freeze
  MOTIVOS_OMISION = %w[intervalo sin_correo sin_destinatarios].freeze

  belongs_to :lectura
  belongs_to :variable_evento
  belongs_to :sensor
  belongs_to :variable
  belongs_to :finca

  validates :tipo, inclusion: { in: TIPOS }
  validates :severidad, inclusion: { in: VariableEvento::SEVERIDADES }
  validates :motivo_omision, inclusion: { in: MOTIVOS_OMISION }, allow_nil: true

  scope :recientes, -> { order(created_at: :desc) }

  # Hubo un correo encolado o enviado para este sensor + evento desde `desde`.
  # Cuenta las encoladas y no solo las enviadas: en un sync IoT las lecturas se
  # evalúan antes de que el job del primer correo haya corrido.
  def self.notificada_desde?(sensor_id, evento_id, desde, excepto_id: nil)
    where(sensor_id: sensor_id, variable_evento_id: evento_id, notificacion_omitida: false)
      .where(created_at: desde..)
      .where.not(id: excepto_id)
      .exists?
  end
end
