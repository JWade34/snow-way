# Plain-English, data-backed answers about one resort's snow outlook.
# Shared by the resort page (answer block + FAQ + FAQPage schema) and /llms-full.txt,
# so what search engines and AI crawlers read always matches what people see.
class ResortSummary
  include ActionView::Helpers::NumberHelper

  SNOW_DAY_INCHES = 1.0
  PEER_LIMIT = 5

  attr_reader :resort, :as_of

  # totals: Resort.projected_totals, passed in so a list of summaries shares one query.
  def initialize(resort, totals: nil, totals_14: nil, as_of: Date.current)
    @resort = resort
    @as_of = as_of
    @totals = totals
    @totals_14 = totals_14
  end

  def totals
    @totals ||= Resort.projected_totals(as_of)
  end

  def totals_14
    @totals_14 ||= Resort.projected_totals(as_of, days: 14)
  end

  def total_14
    totals_14.fetch(resort.id, 0.0)
  end

  # Days 8-14: longer-range and less reliable, shown separately from the 7-day ranking.
  def extended_forecasts
    @extended_forecasts ||= resort.snow_forecasts
      .select { |f| ((as_of + 7)..(as_of + 13)).cover?(f.forecast_date) }
      .sort_by(&:forecast_date)
  end

  # Forecast rows for the next 7 days, in date order.
  def forecasts
    @forecasts ||= resort.snow_forecasts
      .select { |f| Resort.forecast_window(as_of).cover?(f.forecast_date) }
      .sort_by(&:forecast_date)
  end

  def total
    totals.fetch(resort.id, 0.0)
  end

  def recent
    @recent ||= resort.snow_forecasts
      .select { |f| ((as_of - 2)..(as_of - 1)).cover?(f.forecast_date) }
      .sum { |f| f.snowfall_inches.to_f }.round(1)
  end

  def rank
    totals.values.count { |v| v > total } + 1
  end

  def ranked_count
    totals.size
  end

  def biggest_day
    day = forecasts.max_by { |f| f.snowfall_inches.to_f }
    day if day && day.snowfall_inches.to_f > 0
  end

  def next_snow_day
    forecasts.find { |f| f.snowfall_inches.to_f >= SNOW_DAY_INCHES }
  end

  def forecast_through
    Resort.forecast_window(as_of).last
  end

  def updated_at
    @updated_at ||= resort.snow_forecasts.map(&:created_at).max
  end

  def has_forecast?
    forecasts.any?
  end

  # Same state/province resorts with their totals, most snow first.
  def state_peers
    @state_peers ||= begin
      peers = Resort.where(state_province: resort.state_province).where.not(id: resort.id).to_a
      peers.sort_by { |r| -totals.fetch(r.id, 0.0) }.first(PEER_LIMIT)
    end
  end

  def total_for(other)
    totals.fetch(other.id, 0.0)
  end

  # The first paragraph on the page: the direct answer, with numbers and a date.
  def answer
    return "#{resort.name} forecast data is refreshing. Check back shortly for the 7-day snow outlook." unless has_forecast?

    parts = []
    if total > 0
      parts << "As of #{long_date(as_of)}, #{resort.name} is forecast to get #{inches(total)} of snow over the next 7 days, " \
               "ranking ##{rank} of #{ranked_count} North American ski resorts Snow Way tracks."
      parts << "The biggest day is #{day_label(biggest_day.forecast_date)} with #{inches(biggest_day.snowfall_inches)}." if biggest_day
    else
      parts << "As of #{long_date(as_of)}, #{resort.name} has no new snow in the forecast for the next 7 days."
    end
    parts << "It picked up #{inches(recent)} in the last 48 hours." if recent > 0
    parts.join(" ")
  end

  def faqs
    return [] unless has_forecast?

    list = [
      { question: "Will it snow at #{resort.name} this week?", answer: snow_this_week_answer },
      { question: "When is snow expected at #{resort.name}?", answer: next_snow_answer },
      { question: "How much snow has #{resort.name} gotten in the last 48 hours?", answer: recent_answer }
    ]
    list << { question: "How does #{resort.name} compare to other #{resort.state_province} ski resorts this week?", answer: peers_answer } if state_peers.any?
    list << { question: "What is the 14-day snow forecast for #{resort.name}?", answer: fourteen_day_answer } if extended_forecasts.any?
    list << { question: "Is #{resort.name} on the Epic or Ikon Pass?", answer: pass_answer } if resort.pass.present?
    list << { question: "When does #{resort.name} open for the #{season_label} season?", answer: opening_answer } if resort.opening_date
    list << { question: "What is the closest airport to #{resort.name}?", answer: airport_answer }
    list << { question: "How high is #{resort.name}?", answer: elevation_answer } if resort.vertical_drop
    list
  end

  private

  def snow_this_week_answer
    if total > 0
      days = forecasts.count { |f| f.snowfall_inches.to_f > 0 }
      "Yes. #{resort.name} is forecast to get #{inches(total)} of snow from #{short_date(as_of)} through #{short_date(forecast_through)}, " \
        "with snow on #{days} of the next 7 days#{biggest_day ? " and the most on #{day_label(biggest_day.forecast_date)} (#{inches(biggest_day.snowfall_inches)})" : ""}."
    else
      "No new snow is forecast at #{resort.name} from #{short_date(as_of)} through #{short_date(forecast_through)}. Snow Way updates this forecast every day."
    end
  end

  def next_snow_answer
    if (day = next_snow_day)
      "The next day with 1 inch or more in the forecast is #{day_label(day.forecast_date)}, with #{inches(day.snowfall_inches)} expected."
    else
      "No day with 1 inch or more of snow is in the forecast through #{short_date(forecast_through)}. Snow Way checks the forecast daily, so this updates as storms appear."
    end
  end

  def recent_answer
    if recent > 0
      "#{resort.name} picked up about #{inches(recent)} of snow over the last 48 hours (#{short_date(as_of - 2)} to #{short_date(as_of - 1)})."
    else
      "#{resort.name} has had no measurable new snow in the last 48 hours (#{short_date(as_of - 2)} to #{short_date(as_of - 1)})."
    end
  end

  def peers_answer
    others = state_peers.map { |r| "#{r.name} (#{inches(total_for(r))})" }.to_sentence
    lead = total > 0 ? "#{resort.name} is forecast to get #{inches(total)} over the next 7 days." : "#{resort.name} has no new snow in the 7-day forecast."
    "#{lead} Other #{resort.state_province} resorts: #{others}."
  end

  def fourteen_day_answer
    extra = (total_14 - total).round(1)
    base = "#{resort.name} is forecast to get #{inches(total_14)} of snow over the next 14 days (#{short_date(as_of)} to #{short_date(as_of + 13)})"
    detail = extra > 0 ? ", including #{inches(extra)} in days 8 to 14." : ", with nothing more expected in days 8 to 14."
    "#{base}#{detail} Forecasts beyond about 7 days are low-confidence and change often."
  end

  def pass_answer
    case resort.pass
    when "independent" then "#{resort.name} is not on the Epic Pass or the Ikon Pass for #{season_label}.#{other_passes_sentence}"
    else "#{resort.name} is on the #{resort.pass_label} for #{season_label}#{resort.pass_note.present? ? " (#{resort.pass_note})" : ""}.#{other_passes_sentence}"
    end
  end

  OTHER_PASS_NAMES = { "mountain_collective" => "Mountain Collective", "indy" => "Indy Pass" }.freeze

  def other_passes_sentence
    names = Array(resort.other_passes).filter_map { |p| OTHER_PASS_NAMES[p] }
    names.any? ? " It is also on the #{names.to_sentence}." : ""
  end

  def opening_answer
    date = resort.opening_date.strftime("%B %-d, %Y")
    if resort.opening_status == "opened"
      "#{resort.name} opened for the #{season_label} season on #{date}."
    elsif resort.opening_date < as_of
      "#{resort.name} was scheduled to open on #{date}. Check the resort's website to confirm it opened on time."
    else
      "#{resort.name} is scheduled to open on #{date}. Opening dates depend on snow and can change."
    end
  end

  def season_label
    year = as_of.month >= 7 ? as_of.year : as_of.year - 1
    "#{year}-#{(year + 1).to_s.last(2)}"
  end

  def airport_answer
    "The nearest major airport to #{resort.name} is #{resort.airport_name} (#{resort.nearest_airport_code})."
  end

  def elevation_answer
    "#{resort.name}'s summit sits at #{feet(resort.elevation_summit)} and its base at #{feet(resort.elevation_base)}, " \
      "a vertical drop of #{feet(resort.vertical_drop)}."
  end

  def inches(value)
    "#{value.to_f.round(1)}\""
  end

  def feet(value)
    "#{number_with_delimiter(value)} ft"
  end

  def long_date(date)
    date.strftime("%A, %B %-d, %Y")
  end

  def short_date(date)
    date.strftime("%b %-d")
  end

  def day_label(date)
    return "today" if date == as_of
    return "tomorrow" if date == as_of + 1
    date.strftime("%A, %b %-d")
  end
end
