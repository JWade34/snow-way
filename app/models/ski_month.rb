# "Best places to ski in December" pages. Ranks resorts by how often it snows in that month
# (PowderOdds: share of days with 1"+ of new snow over 10 seasons; measured where a SNOTEL station exists,
# modeled in a separate list elsewhere), plus live forecast and opening dates.
class SkiMonth
  SLUGS = %w[november december january february march april].freeze
  REGIONS = [ "Colorado", "Utah", "California", "Wyoming", "Montana", "Idaho", "Washington", "Oregon",
              "Vermont", "New Hampshire", "Maine", "New York", "British Columbia", "Alberta", "Quebec" ].freeze

  attr_reader :slug

  def self.all = SLUGS.map { |s| new(s) }

  def self.find(slug)
    SLUGS.include?(slug) or raise ActiveRecord::RecordNotFound
    new(slug)
  end

  # The month page that matters most right now (this month, or the next ski month in summer).
  def self.current(today = Date.current)
    all.find { |m| m.number == today.month } || new("november")
  end

  def initialize(slug)
    @slug = slug
  end

  def to_param = slug
  def number = Date::MONTHNAMES.index(slug.capitalize)
  def name = Date::MONTHNAMES[number]

  # The upcoming or current season's year for this month (in Nov 2026: December 2026, January 2027).
  def year(today = Date.current)
    season_start = today.month >= 7 ? today.year : today.year - 1
    number >= 7 ? season_start : season_start + 1
  end

  def days = Time.days_in_month(number, year)

  # [[resort, odds_percent], ...] best first, measured at SNOTEL stations (western US resorts with an approved
  # station). Ties go to the resort with more sourced annual snowfall.
  def ranked(scope = Resort.north_america)
    rank(scope) { |r| PowderOdds.measured(r) }
  end

  # The same, modeled, for resorts with no approved station (the East, Canada, Aspen, Mammoth...). Never merged
  # with ranked: measured days run about 1.4x the model's.
  def modeled(scope = Resort.north_america)
    rank(scope.to_a.reject { |r| PowderOdds.station(r) }) { |r| PowderOdds.for(r) }
  end

  def rank(scope)
    scope.to_a.filter_map { |r| (o = yield(r)&.dig(number)) && [ r, o ] }
      .sort_by { |r, o| [ -o, -(AverageSnowfall.for(r)&.dig("inches")).to_i, r.name ] }
  end

  def powder_days(odds) = (odds / 100.0 * days).round
end
