class Sensor < ApplicationRecord
  self.table_name = "sensores"

  belongs_to :finca
  belongs_to :cultivo, optional: true
  has_many :sensor_variables, dependent: :destroy
  has_many :variables, through: :sensor_variables
  has_many :lecturas, dependent: :destroy

  validates :codigo, presence: true, length: { maximum: 100 },
            uniqueness: { scope: :finca_id, case_sensitive: false }
  validates :nombre, presence: true, length: { maximum: 255 }
  validates :lat, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :lng, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  scope :activos,   -> { where(activo: true) }
  scope :inactivos, -> { where(activo: false) }

  def toggle_activo!
    update!(activo: !activo)
  end
end
