# Thursday "where it's snowing this week" email. Goes only to subscribers who agreed to it
# (weekly_report), once per email address per week, skipping weeks with no meaningful snow.
class WeeklyReportJob < ApplicationJob
  queue_as :default

  MIN_TOP_INCHES = 3

  def perform
    totals = Resort.projected_totals.slice(*Resort.north_america.ids)
    resorts = Resort.where(id: totals.keys).index_by(&:id)
    ranked = totals.sort_by { |_, v| -v }.filter_map { |id, v| [ resorts[id], v ] if resorts[id] }.first(8)
    return if ranked.empty? || ranked.first.last < MIN_TOP_INCHES

    Subscriber.where(weekly_report: true, unsubscribed_at: nil)
      .where("weekly_sent_at IS NULL OR weekly_sent_at < ?", 6.days.ago)
      .order(:created_at).group_by(&:email).each_value do |rows|
        subscriber = rows.first
        mine = rows.filter_map { |r| r.resort && [ r.resort, totals[r.resort_id].to_f ] }.uniq
        SubscriberMailer.weekly_report(subscriber, ranked, mine).deliver_later
        Subscriber.where(id: rows.map(&:id)).update_all(weekly_sent_at: Time.current)
      end
  end
end
