# Emails powder alerts after each full forecast refresh. One alert per subscriber per 3 days at most.
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
  end

  private

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
