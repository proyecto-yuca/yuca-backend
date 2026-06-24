class Variable < ApplicationRecord
  validates :nombre, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
  validates :unidad, presence: true, length: { maximum: 100 }
  validates :decimales, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
end
