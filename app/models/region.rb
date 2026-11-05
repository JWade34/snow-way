# A state or province, built from resort data. Powers /ski-resorts/:slug directory pages.
class Region
  attr_reader :name, :country, :resorts

  def self.all
    Resort.order(:name).to_a.group_by(&:state_province)
      .map { |name, resorts| new(name, resorts.first.country, resorts) }
      .sort_by { |r| [ r.country == "USA" ? 0 : 1, r.name ] }
  end

  def self.find(slug)
    all.find { |r| r.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  def initialize(name, country, resorts)
    @name = name
    @country = country
    @resorts = resorts
  end

  def slug
    name.parameterize
  end

  def to_param
    slug
  end
end
