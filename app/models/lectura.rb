class Lectura < ApplicationRecord
  belongs_to :sensor
  belongs_to :variable
  has_many :alertas, dependent: :delete_all

  validates :valor, presence: true, numericality: true
  validates :fecha, :hora_registro, presence: true
  validates :variable_id, uniqueness: { scope: [ :sensor_id, :fecha, :hora_registro ] }

  scope :en_rango,        ->(desde, hasta) { where(fecha: desde..hasta) }
  scope :por_variable,    ->(variable_id) { where(variable_id: variable_id) if variable_id.present? }
  scope :cronologico_desc, -> { order(fecha: :desc, hora_registro: :desc) }

  # Lecturas que incumplen al menos un evento activo de su variable.
  scope :fuera_de_rango, -> {
    where(<<~SQL.squish)
      EXISTS (
        SELECT 1 FROM variable_eventos ve
        WHERE ve.variable_id = lecturas.variable_id
          AND ve.activo
          AND ((ve.rango_min IS NOT NULL AND lecturas.valor < ve.rango_min)
            OR (ve.rango_max IS NOT NULL AND lecturas.valor > ve.rango_max))
      )
    SQL
  }

  after_create_commit :evaluar_eventos

  private

  def evaluar_eventos
    Alertas::EvaluarLectura.call(self)
  end
end
