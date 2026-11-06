# Justin's first-hand notes from db/local_takes.yml (he lived in Vail and Salt Lake City).
class LocalTake
  FILE = Rails.root.join("db/local_takes.yml")

  def self.data
    @data = nil if Rails.env.development?
    @data ||= (YAML.load_file(FILE) || {}).with_indifferent_access
  end

  def self.for_resort(slug)
    data.dig(:resorts, slug)
  end

  def self.for_guide(slug)
    data.dig(:guides, slug)
  end
end
