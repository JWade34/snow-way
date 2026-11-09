# Sourced list pages (best winter vacations, best ski towns, beginner resorts, Colorado hot springs)
# from db/travel_lists.yml. Every entry carries its own sources.
module TravelList
  FILE = Rails.root.join("db/travel_lists.yml")
  PAGES = {
    "winter_vacations" => "/best-winter-vacations-in-the-us", "ski_towns" => "/best-ski-towns",
    "beginner_resorts" => "/best-ski-resorts-for-beginners", "hot_springs" => "/hot-springs-in-colorado"
  }.freeze

  module_function

  def data
    @data = nil if Rails.env.development?
    @data ||= File.exist?(FILE) ? (YAML.load_file(FILE) || {}) : {}
  end

  def list(key) = Array(data[key])
  def paths = PAGES.select { |key, _| list(key).any? }.values

  # { slug => Resort } for every resort slug a list mentions.
  def resorts
    slugs = data.values.grep(Array).flatten.grep(Hash).flat_map { |e| [ e["slug"], *Array(e["resorts"]), e["nearest_resort"] ] }.compact
    Resort.where(slug: slugs.uniq).index_by(&:slug)
  end
end
