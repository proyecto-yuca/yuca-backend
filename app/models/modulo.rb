class Modulo < ApplicationRecord
  self.table_name = "modulos"

  has_many :permisos, dependent: :destroy

  validates :identificador, presence: true, uniqueness: { case_sensitive: false }
  validates :nombre, presence: true, length: { maximum: 100 }
  validates :orden, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  default_scope { order(:orden) }
end
