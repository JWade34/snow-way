# The /new-england page: Vermont, New Hampshire and Maine ranked by the 7-day snow forecast,
# with snow already on the ground (yesterday, 48 hours, 7 days) and a weekend trip window.
# Built for the Boston Globe ski forecast column (Ken Mahan, 2026-11-20): New Englanders check
# the projection a day to a week out, then drive up for the weekend.
class NewEnglandReport
  STATES = [ "Vermont", "New Hampshire", "Maine" ].freeze

  Row = Struct.new(:resort, :week, :summit_week, :yesterday, :two_days, :past_week, :snow_days, keyword_init: true)

  attr_reader :as_of

  def initialize(as_of = Date.current)
    @as_of = as_of
  end

  def resorts
    @resorts ||= Resort.where(state_province: STATES).to_a
  end

  def rows
    @rows ||= begin
      ids = resorts.map(&:id)
      week = Resort.projected_totals(as_of).slice(*ids)
      summit = Resort.projected_summit_totals(as_of).slice(*ids)
      yesterday = past_totals(as_of - 1, as_of - 1, ids)
      two_days = past_totals(as_of - 2, as_of - 1, ids)
      past_week = past_totals(as_of - 7, as_of - 1, ids)
      season = (PowderStudy.season(:measured) + PowderStudy.season(:weather)).to_h { |r, days, _| [ r.id, days ] }
      resorts.map do |r|
        Row.new(resort: r, week: week.fetch(r.id, 0.0), summit_week: summit.fetch(r.id, 0.0),
                yesterday: yesterday.fetch(r.id, 0.0), two_days: two_days.fetch(r.id, 0.0), past_week: past_week.fetch(r.id, 0.0),
                snow_days: season[r.id])
      end.sort_by { |row| [ -row.week, -row.summit_week, -row.past_week, row.resort.name ] }
    end
  end

  def by_state
    STATES.map { |s| [ s, rows.select { |row| row.resort.state_province == s } ] }
  end

  def leader
    rows.first
  end

  def fresh
    rows.select { |row| row.two_days > 0 }.sort_by { |row| -row.two_days }
  end

  # Friday to Sunday of the next weekend people can still plan for: this one through Friday, next one from Saturday on.
  def weekend
    friday = as_of + ((5 - as_of.wday) % 7)
    { checkin: friday, checkout: friday + 2 }
  end

  def picks
    rows.select { |row| row.week > 0 }.first(3)
  end

  def updated_at
    @updated_at ||= SnowForecast.where(resort_id: resorts.map(&:id)).maximum(:created_at)
  end

  def weekend_label
    "#{weekend[:checkin].strftime("%a %b %-d")} to #{weekend[:checkout].strftime("%a %b %-d")}"
  end

  # Plain data (strings and hashes) so it caches cleanly: FAQs, meta description and the ranked list for JSON-LD.
  def meta
    { faqs: faqs, list: rows.map { |row| [ row.resort.name, row.resort.slug ] },
      description: "#{faqs.first[:answer]} 7-day snow forecasts plus the last 24 hours, 48 hours and 7 days for #{rows.size} resorts.".truncate(300) }
  end

  def faqs
    today = as_of.strftime("%B %-d, %Y")
    lead = leader
    list = []
    list << { question: "Which New England ski resort is getting the most snow this week?",
              answer: lead && lead.week > 0 ? "As of #{today}, #{lead.resort.name} in #{lead.resort.state_province} leads Vermont, New Hampshire and Maine with #{inches(lead.week)} forecast over the next 7 days at mid-mountain (#{inches(lead.summit_week)} at the summit)#{(runners = picks[1..2] || []).any? ? ", followed by #{runners.map { |x| "#{x.resort.name} (#{inches(x.week)})" }.to_sentence}" : ""}." : "As of #{today}, no ski resort in Vermont, New Hampshire or Maine has new snow in its 7-day forecast." }
    by_state.each do |state, state_rows|
      top = state_rows.first
      list << { question: "What is the #{state} ski forecast this week?",
                answer: top && top.week > 0 ? "#{top.resort.name} has the most snow forecast in #{state} over the next 7 days: #{inches(top.week)} at mid-mountain and #{inches(top.summit_week)} at the summit. #{state_rows.count { |x| x.week > 0 }} of #{state_rows.size} #{state} resorts Snow Way tracks have snow in the forecast." : "None of the #{state_rows.size} #{state} ski resorts Snow Way tracks has new snow in its 7-day forecast as of #{today}." }
    end
    past = rows.select { |x| x.past_week > 0 }.sort_by { |x| -x.past_week }
    list << { question: "How much snow has New England gotten in the last week?",
              answer: past.any? ? "Over the last 7 days, #{past.first(3).map { |x| "#{x.resort.name} got about #{inches(x.past_week)}" }.to_sentence}, based on weather-model estimates at mid-mountain." : "The weather models show no measurable new snow at New England ski resorts over the last 7 days." }
    list << { question: "Where should I ski in New England this weekend?",
              answer: picks.any? ? "For the weekend of #{weekend_label}, the most new snow is forecast at #{picks.map { |x| "#{x.resort.name} (#{inches(x.week)})" }.to_sentence}. Forecasts change daily, so check again the day before you drive up." : "No New England resort has new snow in the 7-day forecast yet. Resorts with snowmaking and high summits hold up best in a dry week." }
    list << { question: "Where does this New England snow forecast come from?",
              answer: "Snow Way pulls weather-model forecasts from Open-Meteo for two points at each resort, mid-mountain and the summit, and refreshes them every 6 hours. The snow-days-per-season numbers come from 10 winters of NOAA weather-station records (2015-16 to 2024-25), not from a model." }
  end

  private

  def inches(value) = "#{value.to_f.round(1)}\""

  def past_totals(from, to, ids)
    SnowForecast.where(resort_id: ids, forecast_date: from..to).group(:resort_id).sum(:snowfall_inches)
      .transform_values { |v| v.to_f.round(1) }
  end
end
