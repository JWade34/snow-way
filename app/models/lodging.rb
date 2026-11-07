# "Where to stay" guides for the most-booked resorts. Data lives in db/lodging.yml.
class Lodging
  FILE = Rails.root.join("db/lodging.yml")
  ACCESS = {
    "slopeside" => "Ski-in/ski-out or steps from a lift",
    "walk" => "Short walk to a lift",
    "shuttle" => "Bus, shuttle, or gondola to the lifts",
    "drive" => "Drive to the lifts"
  }.freeze

  Area = Struct.new(:name, :search, :access, :price, :best_for, :note, keyword_init: true) do
    def access_label = ACCESS.fetch(access)
    def slopeside? = access == "slopeside"
  end

  attr_reader :slug, :summary, :areas

  def self.data
    @data = nil if Rails.env.development?
    @data ||= YAML.load_file(FILE)
  end

  def self.slugs
    data.keys
  end

  def self.for(resort)
    attrs = data[resort.slug] or return
    new(resort.slug, attrs)
  end

  def initialize(slug, attrs)
    @slug = slug
    @summary = attrs.fetch("summary")
    @areas = attrs.fetch("areas").map { |a| Area.new(**a.symbolize_keys) }
  end

  def slopeside
    areas.select(&:slopeside?)
  end

  def cheapest
    areas.min_by { |a| a.price.length }
  end
end
