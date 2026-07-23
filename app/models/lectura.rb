class Lectura < ApplicationRecord
  belongs_to :sensor
  belongs_to :variable

  validates :valor, presence: true, numericality: true
  validates :fecha, :hora_registro, presence: true
  validates :variable_id, uniqueness: { scope: [ :sensor_id, :fecha, :hora_registro ] }

  scope :en_rango,        ->(desde, hasta) { where(fecha: desde..hasta) }
  scope :por_variable,    ->(variable_id) { where(variable_id: variable_id) if variable_id.present? }
  scope :cronologico_desc, -> { order(fecha: :desc, hora_registro: :desc) }
end
