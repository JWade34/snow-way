# "Things to do in Breckenridge in winter" pages, from db/winter_towns.yml (every activity names a
# real business with its official link; prices only as listed, with the date).
class WinterTown
  FILE = Rails.root.join("db/winter_towns.yml")
  CATEGORIES = {
    "snowmobile" => [ "🛷", "Snowmobiling" ], "dog-sled" => [ "🐕", "Dog sledding" ], "sleigh-ride" => [ "🐴", "Sleigh rides" ],
    "hot-springs" => [ "♨️", "Hot springs" ], "ice-skating" => [ "⛸️", "Ice skating" ], "tubing" => [ "🛝", "Tubing" ],
    "snowshoe" => [ "🥾", "Snowshoeing" ], "nordic" => [ "⛷️", "Cross-country skiing" ], "scenic" => [ "🚡", "Scenic rides" ],
    "museum" => [ "🏛️", "Museums and history" ], "food-drink" => [ "🍲", "Food and drink" ], "festival" => [ "🎉", "Festivals" ],
    "other" => [ "❄️", "More to do" ]
  }.freeze

  attr_reader :slug, :data

  def self.data
    @data = nil if Rails.env.development?
    @data ||= File.exist?(FILE) ? (YAML.load_file(FILE) || {}) : {}
  end

  def self.all = data.map { |slug, d| new(slug, d) }.select { |t| t.resorts.any? }
  def self.find(slug) = all.find { |t| t.slug == slug } || raise(ActiveRecord::RecordNotFound)
  def self.for_resort(resort) = all.select { |t| t.resorts.map(&:id).include?(resort.id) }

  def initialize(slug, data)
    @slug, @data = slug, data
  end

  def to_param = slug
  def name = data["name"]
  def state = data["state"]
  def place = [ name, state ].compact.join(", ")
  def title = "Things to do in #{name} in winter"
  def path = "/things-to-do-in-#{slug}-in-winter"

  def resorts
    @resorts ||= Resort.where(slug: Array(data["resorts"])).index_by(&:slug).values_at(*Array(data["resorts"])).compact
  end

  def primary = resorts.first
  def activities = Array(data["activities"])
  def by_category = activities.group_by { |a| CATEGORIES.key?(a["category"]) ? a["category"] : "other" }.sort_by { |c, _| CATEGORIES.keys.index(c) }
  def bookable = activities.select { |a| a["tour_query"].present? }

  %w[intro non_skier_tip].each { |key| define_method(key) { data[key] } }
  def free = Array(data["free"])
  def events = Array(data["events"])
  def sources = Array(data["sources"])
  def others = self.class.all.reject { |t| t.slug == slug }
end
