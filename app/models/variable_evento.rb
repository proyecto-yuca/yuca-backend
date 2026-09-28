# Regla de tolerancia de una variable: rango permitido + a quién avisar por correo
# cuando una lectura sale de él. Una variable puede tener varios eventos.
class VariableEvento < ApplicationRecord
  SEVERIDADES = %w[alerta critico].freeze
  MAX_EMAILS  = 10

  belongs_to :variable, inverse_of: :eventos
  has_many :alertas, dependent: :destroy

  scope :activos, -> { where(activo: true) }

  before_validation :normalizar_emails

  validates :nombre, presence: true, length: { maximum: 255 },
            uniqueness: { scope: :variable_id, case_sensitive: false }
  validates :severidad, inclusion: { in: SEVERIDADES }
  validates :rango_min, :rango_max, numericality: true, allow_nil: true
  validates :intervalo_minutos, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validate :al_menos_un_limite
  validate :rango_ordenado
  validate :emails_validos

  # "bajo", "alto" o nil si el valor está dentro del rango.
  def evaluar(valor)
    return nil if valor.nil?

    v = valor.to_d
    return "bajo" if rango_min && v < rango_min
    return "alto" if rango_max && v > rango_max

    nil
  end

  def critico?
    severidad == "critico"
  end

  private

  def normalizar_emails
    self.emails = Array(emails).map { |e| e.to_s.strip.downcase }.reject(&:blank?).uniq
  end

  def al_menos_un_limite
    return if rango_min.present? || rango_max.present?

    errors.add(:rango_min, "debe definir un mínimo o un máximo")
  end

  def rango_ordenado
    return unless rango_min.present? && rango_max.present?
    return if rango_min < rango_max

    errors.add(:rango_min, "debe ser menor que el máximo")
  end

  def emails_validos
    if emails.size > MAX_EMAILS
      errors.add(:emails, "no puede tener más de #{MAX_EMAILS} correos")
    end

    if notificar_email? && emails.empty?
      errors.add(:emails, "debe tener al menos un correo si la notificación por correo está activa")
    end

    emails.reject { |e| e.match?(URI::MailTo::EMAIL_REGEXP) }.each do |email|
      errors.add(:emails, "correo inválido: #{email}")
    end
  end
end
