# Sends one push notification outside the web request.
class PushDeliveryJob < ApplicationJob
  queue_as :default

  def perform(push_subscription_id, title:, body:, url:, tag: "powder")
    PushSubscription.find_by(id: push_subscription_id)&.deliver(title:, body:, url:, tag:)
  end
end
