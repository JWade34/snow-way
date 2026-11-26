# A browser or installed app that asked for powder alerts as phone notifications (Web Push).
# Holds no personal data: just the push service address the browser gave us and the alert settings.
class PushSubscription < ApplicationRecord
  belongs_to :resort, optional: true

  MAX_FAILURES = 5 # temporary push service errors in a row before we stop trying

  PLATFORMS = %w[web ios].freeze

  validates :platform, inclusion: { in: PLATFORMS }
  validates :endpoint, presence: true, length: { maximum: 1000 }, uniqueness: { scope: :resort_id }
  validates :endpoint, format: { with: %r{\Ahttps://} }, if: :web?
  validates :endpoint, format: { with: /\A\h{64,200}\z/ }, if: :ios? # APNs device token, hex
  validates :p256dh, :auth, presence: true, length: { maximum: 200 }, if: :web?
  validates :threshold_inches, numericality: { only_integer: true, in: 1..48 }, allow_nil: true

  def self.vapid_public_key = ENV["VAPID_PUBLIC_KEY"].presence
  def self.web_enabled? = vapid_public_key.present? && ENV["VAPID_PRIVATE_KEY"].present?
  def self.enabled? = web_enabled? || Apns.enabled?

  def web? = platform == "web"
  def ios? = platform == "ios"

  # Sends one notification. Returns true when delivered. Forgets subscriptions the push service says are gone.
  def deliver(title:, body:, url:, tag: "powder")
    return deliver_ios(title:, body:, url:, tag:) if ios?
    return false unless self.class.web_enabled?
    WebPush.payload_send(message: { title:, body:, url:, tag: }.to_json, endpoint:, p256dh:, auth:,
                         vapid: { subject: "https://snowway.app/privacy", public_key: self.class.vapid_public_key, private_key: ENV["VAPID_PRIVATE_KEY"] },
                         ttl: 12.hours.to_i, urgency: "normal")
    update_column(:failures, 0) if failures.positive?
    true
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription, WebPush::Unauthorized
    self.class.where(endpoint:).destroy_all # the browser dropped it, for every resort it followed
    false
  rescue WebPush::Error, Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED => e
    Rails.logger.warn("[push] #{e.class} for subscription #{id}")
    failures + 1 >= MAX_FAILURES ? destroy : update_column(:failures, failures + 1)
    false
  end

  private

  def deliver_ios(title:, body:, url:, tag:)
    return false unless Apns.enabled?
    result = Apns.deliver(token: endpoint, title:, body:, url:, tag:)
    if result.gone
      self.class.where(endpoint:).destroy_all
    elsif result.ok
      update_column(:failures, 0) if failures.positive?
    else
      failures + 1 >= MAX_FAILURES ? destroy : update_column(:failures, failures + 1)
    end
    result.ok
  rescue StandardError => e
    Rails.logger.warn("[apns] #{e.class} for subscription #{id}")
    false
  end
end
