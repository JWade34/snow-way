# Official webcam and trail map pages for each resort, from db/resort_links.yml (verified links only).
class ResortLinks
  FILE = Rails.root.join("db/resort_links.yml")

  def self.data
    @data = nil if Rails.env.development?
    @data ||= File.exist?(FILE) ? (YAML.load_file(FILE) || {}) : {}
  end

  def self.for(resort)
    (data[resort.slug] || {}).slice("webcams", "trail_map").compact_blank
  end
end
