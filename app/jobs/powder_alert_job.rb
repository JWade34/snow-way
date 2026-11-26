# Sends powder alerts after each full forecast refresh: emails to subscribers and phone notifications to
# push subscriptions. One alert per subscriber or device per 3 days at most.
class PowderAlertJob < ApplicationJob
  queue_as :default

  GENERAL_THRESHOLD = 12 # inches in 3 days, for subscribers without a specific resort
  COOLDOWN = 3.days

  def perform
    totals = Resort.projected_totals(days: 3)
    return if totals.empty?

    resorts = Resort.where(id: totals.keys).index_by(&:id)
    ranked = totals.sort_by { |_, v| -v }.map { |id, v| [ resorts[id], v ] }.select(&:first)

    Subscriber.where(unsubscribed_at: nil).where("last_alerted_at IS NULL OR last_alerted_at < ?", COOLDOWN.ago).find_each do |subscriber|
      alerts = alerts_for(subscriber, totals, resorts, ranked)
      next if alerts.blank?

      SubscriberMailer.powder_alert(subscriber, alerts).deliver_later
      subscriber.update_column(:last_alerted_at, Time.current)
    end

    return unless PushSubscription.enabled? # deliver skips a platform whose keys aren't set
    PushSubscription.where("last_alerted_at IS NULL OR last_alerted_at < ?", COOLDOWN.ago).find_each do |sub|
      alerts = alerts_for(sub, totals, resorts, ranked)
      next if alerts.blank?

      PushDeliveryJob.perform_later(sub.id, **self.class.push_message(alerts))
      sub.update_column(:last_alerted_at, Time.current)
    end
  end

  # Notification text: the lead resort in the title, the next few in the body. Opens that resort's page.
  def self.push_message(alerts)
    (resort, inches), *others = alerts
    body = others.any? ? "Also: " + others.first(3).map { |r, v| "#{r.name} #{v.round}\"" }.join(", ") : "Tap for the forecast."
    { title: "#{resort.name}: #{inches.round}\" in the next 3 days", body: body,
      url: "/resorts/#{resort.slug}?utm_source=push&utm_medium=notification&utm_campaign=powder_alert", tag: "powder-#{resort.slug}" }
  end

  private

  # Works for email subscribers and push subscriptions: both have resort_id and threshold_inches.
  def alerts_for(subscriber, totals, resorts, ranked)
    if subscriber.resort_id
      inches = totals[subscriber.resort_id].to_f
      return if inches < (subscriber.threshold_inches || 6)
      [ [ resorts[subscriber.resort_id], inches ] ] + ranked.reject { |r, _| r.id == subscriber.resort_id }.select { |_, v| v >= 6 }.first(4)
    else
      top = ranked.select { |_, v| v >= 6 }.first(5)
      top if top.any? && top.first.last >= GENERAL_THRESHOLD
    end
  end
end
