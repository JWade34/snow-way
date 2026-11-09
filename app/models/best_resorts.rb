# "Best ski resorts in Colorado / the US / on the East Coast..." pages. A transparent score from our own
# data, normalized within each list: snow days (PowderStudy, 10 seasons), sourced average annual snowfall
# (AverageSnowfall) and vertical drop. Missing metrics are skipped and the other weights rescale.
class BestResorts
  EAST = [ "Vermont", "New Hampshire", "Maine", "New York", "Massachusetts", "Connecticut", "Pennsylvania", "New Jersey",
           "West Virginia", "Virginia", "North Carolina", "Maryland", "Tennessee" ].freeze
  SCOPES = {
    "in-the-us" => { name: "the US", label: "US", rule: ->(r) { r.country == "USA" } },
    "in-north-america" => { name: "North America", label: "North American", rule: ->(r) { r.north_american? } },
    "in-colorado" => { name: "Colorado", label: "Colorado", rule: ->(r) { r.state_province == "Colorado" }, hub: "denver" },
    "in-utah" => { name: "Utah", label: "Utah", rule: ->(r) { r.state_province == "Utah" }, hub: "salt-lake-city" },
    "in-california" => { name: "California", label: "California", rule: ->(r) { r.state_province == "California" } },
    "in-vermont" => { name: "Vermont", label: "Vermont", rule: ->(r) { r.state_province == "Vermont" }, hub: "boston" },
    "on-the-east-coast" => { name: "the East Coast", label: "East Coast", rule: ->(r) { r.country == "USA" && EAST.include?(r.state_province) }, hub: "new-york-city" },
    "in-japan" => { name: "Japan", label: "Japanese", rule: ->(r) { r.country == "Japan" } }
  }.freeze
  WEIGHTS = { snow_days: 0.4, snowfall: 0.3, vertical: 0.3 }.freeze

  attr_reader :slug

  def self.all = SCOPES.keys.map { |s| new(s) }.select { |b| b.ranked.size >= 5 }
  def self.find(slug) = (SCOPES.key?(slug) && (b = new(slug)).ranked.size >= 5) ? b : raise(ActiveRecord::RecordNotFound)

  def initialize(slug)
    @slug = slug
  end

  def to_param = slug
  def path = "/best-ski-resorts-#{slug}"
  def scope = SCOPES.fetch(slug)
  def name = scope[:name]
  def label = scope[:label]
  def hub = scope[:hub] && SkiHub.all.find { |h| h.slug == scope[:hub] }
  def resorts = @resorts ||= Resort.all.select(&scope[:rule])

  def snow_days
    @snow_days ||= PowderStudy.season.to_h { |r, d, _| [ r.id, d ] }
  end

  def metrics(r)
    { snow_days: snow_days[r.id], snowfall: AverageSnowfall.for(r)&.dig("inches"), vertical: (r.elevation_summit.to_i - r.elevation_base.to_i).nonzero? }
  end

  # [[resort, score 0-100, metrics], ...] best first.
  def ranked
    @ranked ||= begin
      rows = resorts.map { |r| [ r, metrics(r) ] }
      ranges = WEIGHTS.keys.to_h { |k| v = rows.filter_map { |_, m| m[k] }; [ k, v.minmax ] }
      rows.filter_map do |r, m|
        parts = WEIGHTS.filter_map do |k, w|
          lo, hi = ranges[k]
          next unless m[k] && lo && hi
          [ w, hi == lo ? 1.0 : (m[k] - lo).to_f / (hi - lo) ]
        end
        next if parts.sum { |w, _| w } < 0.5 # need most of the data to rank fairly
        [ r, (parts.sum { |w, v| w * v } / parts.sum { |w, _| w } * 100).round, m ]
      end.sort_by { |r, s, _| [ -s, r.name ] }
    end
  end

  def top(n = 15) = ranked.first(n)
  def best_by(key) = ranked.select { |_, _, m| m[key] }.max_by { |_, _, m| m[key] }
end
