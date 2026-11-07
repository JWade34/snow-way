# Head-to-head resort comparisons at /compare/:slug. Written verdicts live in db/comparisons.yml;
# every number on the page comes from live resort data.
class Comparison
  FILE = Rails.root.join("db/comparisons.yml")

  attr_reader :slug, :verdict, :a_if, :b_if, :a_slug, :b_slug

  def self.data
    @data = nil if Rails.env.development?
    @data ||= YAML.load_file(FILE)
  end

  # Only pairs whose resorts both exist.
  def self.all
    slugs = Resort.pluck(:slug).to_set
    data.map { |row| new(row) }.select { |c| slugs.include?(c.a_slug) && slugs.include?(c.b_slug) }
  end

  def self.find(slug)
    all.find { |c| c.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  def self.for_resort(resort)
    all.select { |c| [ c.a_slug, c.b_slug ].include?(resort.slug) }
  end

  def initialize(row)
    @slug, @verdict, @a_if, @b_if = row.values_at("slug", "verdict", "a_if", "b_if")
    @a_slug, @b_slug = row.values_at("a", "b")
  end

  def resorts
    @resorts ||= Resort.includes(:snow_forecasts).where(slug: [ a_slug, b_slug ]).index_by(&:slug).values_at(a_slug, b_slug)
  end

  def a = resorts.first
  def b = resorts.last

  def title
    "#{a.name} vs #{b.name}"
  end

  def to_param
    slug
  end
end
