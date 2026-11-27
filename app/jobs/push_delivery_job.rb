# Sends one push notification outside the web request.
class PushDeliveryJob < ApplicationJob
  queue_as :default

  def perform(push_subscription_id, title:, body:, url:, tag: "powder", **extras)
    PushSubscription.find_by(id: push_subscription_id)&.deliver(title:, body:, url:, tag:, **extras)
  end
end
