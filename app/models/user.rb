class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  belongs_to :rol, optional: true

  has_many :fincas, dependent: :destroy

  scope :activos,   -> { where(estado: true) }
  scope :inactivos, -> { where(estado: false) }

  def admin?
    rol&.admin?
  end

  def toggle_estado!
    update!(estado: !estado)
  end
end
