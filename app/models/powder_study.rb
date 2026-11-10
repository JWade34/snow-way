# The "Powder Day Odds" data study: how often each resort gets 1"+ of new snow, by month and over a Nov-Apr
# season. The study itself uses measured SNOTEL data (western US resorts with an approved station);
# season(:model) is the modeled version for every North American resort, used by lists that must compare all.
module PowderStudy
  REGIONS = {
    "Pacific Northwest" => %w[Washington Oregon], "Western Canada" => [ "British Columbia", "Alberta" ],
    "Northern Rockies" => %w[Montana Idaho Wyoming], "Utah" => %w[Utah], "California and Nevada" => %w[California Nevada],
    "Colorado" => %w[Colorado], "Southwest" => [ "New Mexico", "Arizona" ], "Alaska" => %w[Alaska],
    "Northeast" => [ "Vermont", "New Hampshire", "Maine", "New York", "Massachusetts", "Connecticut" ],
    "Eastern Canada" => %w[Quebec Ontario], "Midwest" => %w[Michigan Wisconsin Minnesota Ohio Indiana South\ Dakota],
    "Mid-Atlantic and South" => [ "Pennsylvania", "New Jersey", "West Virginia", "Virginia", "North Carolina", "Maryland", "Tennessee" ]
  }.freeze

  module_function

  def months = SkiMonth.all

  # [[resort, season_days, {month_number => odds}], ...] most snow days first.
  def season(source = :measured)
    @season = nil if Rails.env.development?
    (@season ||= {})[source] ||= Resort.north_america.to_a.filter_map do |r|
      odds = (source == :measured ? PowderOdds.measured(r) : PowderOdds.for(r)) or next
      days = months.sum { |m| odds[m.number].to_i / 100.0 * m.days }
      [ r, days.round, odds ]
    end.sort_by { |r, d, _| [ -d, r.name ] }
  end

  def month_averages
    months.to_h { |m| v = season.map { |_, _, o| o[m.number].to_i }; [ m, (v.sum.to_f / v.size).round(1) ] }
  end

  # { region => { avg:, count:, best: [resort, days] } } sorted by average.
  def regions
    REGIONS.filter_map do |name, states|
      list = season.select { |r, _, _| states.include?(r.state_province) }
      next if list.size < 2
      [ name, { avg: (list.sum { |_, d, _| d }.to_f / list.size).round, count: list.size, best: list.first.first(2) } ]
    end.sort_by { |_, v| -v[:avg] }.to_h
  end

  def state_leaders
    season.group_by { |r, _, _| r.state_province }.transform_values(&:first).sort_by { |_, (_, d, _)| -d }
  end

  def to_csv
    require "csv"
    CSV.generate do |csv|
      csv << [ "resort", "state_province", "country", "season_snow_days_nov_apr", *months.map { |m| "#{m.slug}_pct_days_with_new_snow" },
               "snotel_station", "snotel_triplet", "station_miles_from_resort", "station_elevation_ft", "full_seasons", "snow_way_url" ]
      season.each do |r, d, o|
        st = PowderOdds.station(r)
        csv << [ r.name, r.state_province, r.country, d, *months.map { |m| o[m.number].to_i }, st["name"], st["triplet"], st["miles"], st["elev"],
                 PowderOdds.measured_data.dig("resorts", r.slug, "seasons"), "https://snowway.app/resorts/#{r.slug}" ]
      end
    end
  end
end
