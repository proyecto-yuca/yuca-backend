class Permiso < ApplicationRecord
  belongs_to :rol
  belongs_to :modulo

  validates :rol_id, uniqueness: { scope: :modulo_id }
end
