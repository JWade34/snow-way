# "Best time to ski in <state>": which month gets new snow most often, from measured USDA SNOTEL data only.
# A state qualifies with MIN_RESORTS resorts that have an approved snow station, so the averages mean something.
# Same counting as the month pages: a snow day is about an inch or more of new snow, averaged over 10 seasons.
class StateBestTime
  MONTHS = [ 11, 12, 1, 2, 3, 4 ].freeze
  MIN_RESORTS = 3
  DAYS = { 11 => 30, 12 => 31, 1 => 31, 2 => 28, 3 => 31, 4 => 30 }.freeze

  attr_reader :name, :resorts

  def self.all
    @all = nil if Rails.env.development?
    @all ||= Resort.north_america.to_a.select { |r| PowderOdds.measured(r) }.group_by(&:state_province)
      .select { |_, rs| rs.size >= MIN_RESORTS }
      .sort_by { |state, rs| [ -rs.size, state ] }
      .map { |state, rs| new(state, rs) }
  end

  def self.slugs = all.map(&:slug)
  def self.find(slug) = all.find { |s| s.slug == slug } || raise(ActiveRecord::RecordNotFound)
  def self.for_state(name) = all.find { |s| s.name == name }

  def initialize(name, resorts)
    @name = name
    @resorts = resorts.sort_by(&:name)
  end

  def slug = name.parameterize
  def to_param = slug
  def month_name(m) = Date::MONTHNAMES[m]

  # Average share of days with new snow, per month, across the state's measured resorts.
  def month_avgs
    @month_avgs ||= MONTHS.to_h { |m| [ m, (resorts.sum { |r| PowderOdds.measured(r)[m].to_i } / resorts.size.to_f).round ] }
  end

  def snow_days(m, pct = month_avgs[m]) = (pct / 100.0 * DAYS[m]).round

  # Months best first; ties go to the later month (deeper base by then).
  def ranked_months = MONTHS.sort_by { |m| [ -month_avgs[m], -MONTHS.index(m) ] }
  def best_month = ranked_months.first
  def runner_up = ranked_months.second
  def worst_month = ranked_months.last

  # [[resort, best month, odds], ...] snowiest first.
  def resort_rows
    resorts.map do |r|
      odds = PowderOdds.measured(r).slice(*MONTHS)
      m, o = odds.max_by { |mm, oo| [ oo, MONTHS.index(mm) ] }
      [ r, m, o ]
    end.sort_by { |r, _, o| [ -o, r.name ] }
  end

  def top_for(m)
    resorts.max_by { |r| [ PowderOdds.measured(r)[m].to_i, r.name ] }
  end

  def answer
    b, s = best_month, runner_up
    lead = top_for(b)
    close = month_avgs[b] - month_avgs[s] <= 1
    "The best time to ski in #{name} for powder is #{month_name(b)}#{close ? ", with #{month_name(s)} nearly tied" : ""}. " \
      "Across #{resorts.size} #{name} resorts with USDA snow stations, #{month_avgs[b]}% of #{month_name(b)} days bring an inch or more " \
      "of new snow, about #{snow_days(b)} days in a typical season#{close ? " (#{month_avgs[s]}% in #{month_name(s)})" : ". #{month_name(s)} is next at #{month_avgs[s]}%"}. " \
      "#{month_name(worst_month)} is the least snowy month at #{month_avgs[worst_month]}%. " \
      "In #{month_name(b)}, #{lead.name} gets new snow most often of any #{name} resort measured, on about #{snow_days(b, PowderOdds.measured(lead)[b])} days."
  end

  def faqs
    b, s = best_month, runner_up
    december = month_avgs[12]
    [
      { question: "What is the best month to ski in #{name}?",
        answer: "#{month_name(b)}. #{name} resorts with snow stations get new snow on #{month_avgs[b]}% of #{month_name(b)} days on average, the most of any ski month. #{month_name(s)} is close behind at #{month_avgs[s]}%." },
      { question: "When is the best time to ski in #{name} for powder?",
        answer: answer },
      { question: "Is December a good time to ski in #{name}?",
        answer: "December gets new snow on #{december}% of days at #{name} resorts with snow stations, #{ranked_months.index(12) + 1}#{ordinal_suffix(ranked_months.index(12) + 1)} of the six main ski months. Christmas to New Year's is the busiest week of the season, so book lodging early." },
      { question: "Which #{name} resort gets new snow most often?",
        answer: (r, m, o = resort_rows.first) && "#{r.name}, in #{month_name(m)}: an inch or more of new snow on #{o}% of days, about #{snow_days(m, o)} days in a typical #{month_name(m)}." }
    ]
  end

  def updated_on = Date.parse(PowderOdds.measured_data["generated_on"].to_s) rescue Date.current

  private

  def ordinal_suffix(n) = n.ordinalize.delete_prefix(n.to_s)
end
