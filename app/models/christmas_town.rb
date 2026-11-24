# "Christmas in [ski town]" pages (2026-11-24). Facts live in db/christmas_towns.yml, each event with a source;
# snow odds come from the same December station data as the Christmas page. Searches (Dec 2025): Aspen 8,100,
# Breckenridge 5,400, Tahoe 4,400, Vail 3,600, Park City 3,600, plus New Year's Eve versions.
class ChristmasTown
  FILE = Rails.root.join("db/christmas_towns.yml")

  def self.data
    @data = nil if Rails.env.development?
    @data ||= YAML.load_file(FILE, permitted_classes: [ Date ])
  end

  def self.all = data.fetch("towns").map { |slug, h| new(slug, h) }
  def self.slugs = data.fetch("towns").keys
  def self.find(slug) = all.find { _1.slug == slug } || raise(ActiveRecord::RecordNotFound)

  attr_reader :slug, :h
  def initialize(slug, h) = (@slug, @h = slug, h)
  def name = h["name"]
  def state = h["state"]
  def place = h["place"]
  def events = Array(h["events"])
  def nye = Array(h["nye"])
  def resort_notes = Array(h["resort_notes"])
  def airports = Array(h["airports"])
  def distinct = h["distinct"]
  def checked_on = Date.parse(self.class.data["checked_on"].to_s)
  def resorts = Resort.where(slug: Array(h["resorts"])).to_a.sort_by { |r| Array(h["resorts"]).index(r.slug) }
  def path = "/christmas-in-#{slug}"

  # "2026-12-05" -> "Saturday, December 5"; "2026-11-20 to 2027-01-03" -> "November 20 to January 3";
  # "2026-12-05, 2026-12-12" -> "December 5 and 12"; "annual: Dec 24" -> "every Dec 24".
  def self.date_label(raw)
    str = raw.to_s
    return str.sub("annual: ", "every ") if str.start_with?("annual")
    dates = str.scan(/\d{4}-\d{2}-\d{2}/).map { Date.parse(_1) }
    return str if dates.empty?
    return dates.first.strftime("%A, %B %-d") if dates.size == 1
    return "#{dates.first.strftime("%B %-d")} to #{dates.last.strftime("%B %-d")}" if str.include?(" to ")
    same = dates.map(&:month).uniq.size == 1
    same ? "#{dates.first.strftime("%B")} #{dates.map(&:day).to_sentence}" : dates.map { _1.strftime("%B %-d") }.to_sentence
  end

  # Events that touch Christmas week (Dec 18 to Jan 1), for the short answer.
  def christmas_week_events
    year = Date.current.month >= 7 ? Date.current.year : Date.current.year - 1
    win = Date.new(year, 12, 18)..Date.new(year + 1, 1, 1)
    events.select do |e|
      str = e["date"].to_s
      next true if str =~ /annual: Dec (2[0-9]|3[01])/
      ds = str.scan(/\d{4}-\d{2}-\d{2}/).map { Date.parse(_1) }
      ds.size >= 2 && str.include?(" to ") ? (ds.first..ds.last).overlap?(win) : ds.any? { win.cover?(_1) }
    end
  end

  def self.short_name(name) = name.to_s.sub(/\s*\([^)]*\)\s*\z/, "")
end
