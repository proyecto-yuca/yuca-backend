class IotCredential < ApplicationRecord
  belongs_to :finca

  attr_reader :secret_id

  validates :client_id, presence: true, uniqueness: true
  validates :secret_id_digest, presence: true

  scope :active, -> { where(active: true) }

  before_validation :ensure_client_id

  def secret_id=(raw_secret)
    @secret_id = raw_secret
    self.secret_id_digest = digest_secret(raw_secret) if raw_secret.present?
  end

  def authenticate_secret_id(raw_secret)
    return false if raw_secret.blank? || secret_id_digest.blank?

    ActiveSupport::SecurityUtils.secure_compare(
      secret_id_digest,
      digest_secret(raw_secret)
    )
  end

  private

  def ensure_client_id
    self.client_id ||= "iot_#{SecureRandom.hex(12)}"
  end

  def digest_secret(raw_secret)
    pepper = Rails.application.secret_key_base
    OpenSSL::Digest::SHA256.hexdigest("#{pepper}:#{raw_secret}")
  end
end
