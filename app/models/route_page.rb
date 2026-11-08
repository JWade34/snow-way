# "Getting there" pages (Denver to Breckenridge, Salt Lake City to Park City...), from db/routes.yml.
# Facts are sourced in the YAML; drive times come from db/route_drives.yml (OSRM, calibrated).
class RoutePage
  FILE = Rails.root.join("db/routes.yml")
  DRIVES = Rails.root.join("db/route_drives.yml")
  ORIGINS = Rails.root.join("db/route_origins.yml")

  attr_reader :slug, :data

  def self.data
    @data = nil if Rails.env.development?
    @data ||= File.exist?(FILE) ? (YAML.load_file(FILE) || {}) : {}
  end

  def self.drives
    @drives = nil if Rails.env.development?
    @drives ||= File.exist?(DRIVES) ? YAML.load_file(DRIVES) : {}
  end

  def self.origins
    @origins ||= YAML.load_file(ORIGINS)
  end

  def self.all
    data.map { |slug, d| new(slug, d) }.select { |p| p.resorts.any? }
  end

  def self.find(slug)
    all.find { |p| p.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  def self.for_resort(resort)
    all.select { |p| p.resorts.map(&:id).include?(resort.id) }
  end

  def initialize(slug, data)
    @slug, @data = slug, data
  end

  def to_param = slug
  def origin = self.class.origins.fetch(data["origin"])
  def origin_name = origin["name"]
  def destination = data["destination"]
  def title = "#{origin_name} to #{destination}"

  def resorts
    @resorts ||= Resort.where(slug: Array(data["resorts"])).index_by(&:slug).values_at(*Array(data["resorts"])).compact
  end

  def primary = resorts.first

  # { "airport" => { "minutes" => 110, "miles" => 81 }, "city" => {...} } or nil
  def drive(resort = primary, from: "airport")
    self.class.drives.dig("routes", slug, resort.slug, from)
  end

  %w[main_route tip via].each { |key| define_method(key) { data[key] } }
  def winter_driving = Array(data["winter_driving"])
  def options = Array(data["options"])
  def fly_closer = Array(data["fly_closer"])
  def sources = Array(data["sources"])
  def related = self.class.all.select { |p| p.data["origin"] == data["origin"] && p.slug != slug }
end
