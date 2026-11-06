# Powder alert signups. Collected now; alert emails go out once an email provider is configured.
class Subscriber < ApplicationRecord
  belongs_to :resort, optional: true

  normalizes :email, with: ->(email) { email.strip.downcase }
  validates :email, presence: true, length: { maximum: 254 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :resort_id }
  validates :threshold_inches, numericality: { only_integer: true, in: 1..48 }, allow_nil: true

  has_secure_token :token
end
