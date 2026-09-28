class Variable < ApplicationRecord
  has_many :lecturas, dependent: :destroy
  has_many :eventos, -> { order(:created_at) }, class_name: "VariableEvento",
           inverse_of: :variable, dependent: :destroy, index_errors: true

  accepts_nested_attributes_for :eventos, allow_destroy: true

  validates :nombre, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
  validates :unidad, presence: true, length: { maximum: 100 }
  validates :decimales, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  validate :nombres_de_eventos_unicos

  # Pares [evento, tipo] de los eventos activos que el valor incumple.
  def eventos_disparados(valor)
    eventos.select(&:activo?).filter_map do |evento|
      tipo = evento.evaluar(valor)
      [ evento, tipo ] if tipo
    end
  end

  # nil si la variable no tiene eventos activos; si no "normal", "alerta" o "critico".
  def estado_para(valor)
    return nil if eventos.none?(&:activo?)

    disparados = eventos_disparados(valor).map(&:first)
    return "normal" if disparados.empty?

    disparados.any?(&:critico?) ? "critico" : "alerta"
  end

  private

  # La unicidad del modelo no ve los eventos nuevos del mismo request.
  def nombres_de_eventos_unicos
    nombres = eventos.reject(&:marked_for_destruction?).map { |e| e.nombre.to_s.strip.downcase }
    return if nombres.uniq.size == nombres.size

    errors.add(:eventos, "no puede tener dos eventos con el mismo nombre")
  end
end
