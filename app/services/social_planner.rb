# Plans a week of social posts (Mountain time). Safe to run repeatedly: existing slots are left alone.
#   Every day 8am: snow report story (daily snow report)
#   Mon 11am: family tip · Wed 11am: gear or trip tip · Thu 8am: weekly snow report post · Sat 9am: first-timer or powder tip
class SocialPlanner
  ZONE = "America/Denver".freeze
  TIP_SLOTS = { 1 => %w[family], 3 => %w[gear trip], 6 => %w[beginner powder trip] }.freeze
  TIP_HOUR = { 1 => 11, 3 => 11, 6 => 9 }.freeze

  def self.plan_week!(start = Time.find_zone(ZONE).today)
    new.plan!(start, 7)
  end

  def plan!(start, days)
    zone = Time.find_zone(ZONE)
    created = []
    days.times do |offset|
      date = start + offset
      created << slot("report", "story", zone.local(date.year, date.month, date.day, 8))
      created << slot("report", "post", zone.local(date.year, date.month, date.day, 8, 5)) if date.thursday?
      if (categories = TIP_SLOTS[date.wday])
        created << tip_slot(categories, zone.local(date.year, date.month, date.day, TIP_HOUR[date.wday]))
      end
    end
    created.compact
  end

  private

  def slot(kind, format, at, tip_slug: nil)
    return nil if at < Time.current || SocialPost.exists?(kind: kind, format: format, scheduled_for: at)
    SocialPost.create!(kind: kind, format: format, scheduled_for: at, tip_slug: tip_slug)
  end

  # Least-recently-used tip from the slot's categories, so the library rotates before anything repeats.
  def tip_slot(categories, at)
    pool = SocialCard.tips.select { |t| categories.include?(t["category"]) }
    last_used = SocialPost.where(kind: "tip").group(:tip_slug).maximum(:scheduled_for)
    tip = pool.min_by { |t| [ last_used[t["slug"]] || Time.at(0), categories.index(t["category"]) ] }
    slot("tip", "post", at, tip_slug: tip["slug"])
  end
end
