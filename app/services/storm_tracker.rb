# Starts, updates and ends iPhone storm trackers (Live Activities) after each forecast refresh.
# A tracker starts when a resort someone follows in the app has a big storm coming in the next 3 days,
# updates every refresh while it lasts, and ends after the storm passes or after 3 days.
module StormTracker
  START_INCHES = 12 # 3-day forecast that starts a tracker
  END_INCHES = 2    # below this the storm is over
  MAX_AGE = 3.days

  module_function

  def run(three = Resort.projected_totals(days: 3), week = Resort.projected_totals(days: 7))
    return unless Apns.enabled?
    update_open(three, week)
    start_new(three, week)
  end

  def state(resort, three, week, headline)
    { resortName: resort.name, next3DaysIn: three[resort.id].to_f.round, next7DaysIn: week[resort.id].to_f.round,
      headline: headline, updatedAt: Time.current.to_i }
  end

  def headline(inches)
    inches >= 24 ? "Huge storm incoming" : inches >= 18 ? "Big storm incoming" : "Storm incoming"
  end

  def start_new(three, week)
    PushSubscription.where(platform: "ios").where.not(live_start_token: nil).where.not(resort_id: nil).includes(:resort).find_each do |sub|
      inches = three[sub.resort_id].to_f
      next if inches < START_INCHES
      next if LiveActivity.where(endpoint: sub.endpoint, resort_id: sub.resort_id).where("started_at > ?", MAX_AGE.ago).exists?
      result = Apns.live_activity(token: sub.live_start_token, event: "start",
                                  state: state(sub.resort, three, week, headline(inches)),
                                  attributes: { slug: sub.resort.slug, resortName: sub.resort.name },
                                  alert: { title: "#{sub.resort.name}: #{inches.round}\" coming", body: "Storm tracker is on your Lock Screen." },
                                  stale_at: 7.hours.from_now)
      if result.ok
        LiveActivity.create!(endpoint: sub.endpoint, resort: sub.resort, started_at: Time.current)
      elsif result.gone
        sub.update_column(:live_start_token, nil)
      end
    end
  end

  def update_open(three, week)
    LiveActivity.open.where.not(push_token: nil).includes(:resort).find_each do |la|
      inches = three[la.resort_id].to_f
      done = la.started_at < MAX_AGE.ago || inches < END_INCHES
      result = Apns.live_activity(token: la.push_token, event: done ? "end" : "update",
                                  state: state(la.resort, three, week, done ? "Storm's done. Go ski it." : headline(inches)),
                                  dismissal_at: (4.hours.from_now if done), stale_at: (7.hours.from_now unless done))
      la.update!(ended_at: Time.current) if done || result.gone
    end
    LiveActivity.open.where(push_token: nil).where("started_at < ?", 1.day.ago).update_all(ended_at: Time.current) # never reported a token
  end
end
