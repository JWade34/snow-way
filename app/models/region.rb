# A state or province, built from resort data. Powers /ski-resorts/:slug directory pages.
class Region
  attr_reader :name, :country, :resorts

  def self.all
    Resort.order(:name).to_a.group_by(&:state_province)
      .map { |name, resorts| new(name, resorts.first.country, resorts) }
      .sort_by { |r| [ r.country == "USA" ? 0 : 1, r.name ] }
  end

  # Multi-state regions people search for ("best ski resorts in New England", "...in Canada").
  GROUPS = {
    "New England" => ->(r) { %w[Vermont New\ Hampshire Maine Massachusetts Connecticut Rhode\ Island].include?(r.state_province) },
    "Canada" => ->(r) { r.country == "Canada" },
    "Lake Tahoe" => ->(r) { %w[palisades-tahoe northstar heavenly kirkwood sierra-at-tahoe sugar-bowl homewood diamond-peak boreal mt-rose].include?(r.slug) },
    "Summit County, Colorado" => ->(r) { %w[breckenridge keystone copper-mountain arapahoe-basin loveland].include?(r.slug) },
    "Southern California" => ->(r) { %w[bear-mountain snow-summit mountain-high].include?(r.slug) }
  }.freeze

  def self.groups
    resorts = Resort.order(:name).to_a
    GROUPS.filter_map do |name, rule|
      members = resorts.select(&rule)
      new(name, members.first.country, members, group: true) if members.size >= 3
    end
  end

  def self.find(slug)
    (all + groups).find { |r| r.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  def initialize(name, country, resorts, group: false)
    @name = name
    @country = country
    @resorts = resorts
    @group = group
  end

  def group?
    @group
  end

  def slug
    name.parameterize
  end

  def to_param
    slug
  end
end
