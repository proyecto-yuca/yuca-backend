class Rol < ApplicationRecord
  self.table_name = "roles"

  has_many :users, foreign_key: :rol_id, dependent: :nullify
  has_many :permisos, dependent: :destroy

  validates :identificador, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[a-z_]+\z/, message: "solo letras minúsculas y guiones bajos" }
  validates :nombre, presence: true, length: { maximum: 100 }

  def admin?
    identificador == "admin"
  end
end
