# Justin's first-hand notes from db/local_takes.yml (he lived in Vail and Salt Lake City).
class LocalTake
  FILE = Rails.root.join("db/local_takes.yml")

  def self.data
    @data = nil if Rails.env.development?
    @data ||= (YAML.load_file(FILE) || {}).with_indifferent_access
  end

  # A take Justin published from the admin area wins over the YAML file.
  def self.for_resort(slug)
    visit = ResortVisit.published.joins(:resort).find_by(resorts: { slug: slug })
    return { take: visit.take, tips: visit.tips_list }.with_indifferent_access if visit
    data.dig(:resorts, slug)
  end

  def self.for_guide(slug)
    data.dig(:guides, slug)
  end
end
