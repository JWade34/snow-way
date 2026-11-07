# Sourced lift ticket prices (db/lift_tickets.yml). Pages exist only where a 2026-27 price has a cited source.
module LiftTickets
  FILE = Rails.root.join("db/lift_tickets.yml")
  SEASON = "2026-27".freeze

  module_function

  def data
    @data = nil if Rails.env.development?
    @data ||= YAML.load_file(FILE, permitted_classes: [ Date ])
  end

  def checked_on
    data["checked_on"]
  end

  def publishable
    (data["resorts"] || {}).select { |_, d| d["season"] == SEASON && (d["window_high"] || d["window_low"]) && Array(d["sources"]).any? }
  end

  def slugs
    publishable.keys
  end

  def for(resort)
    publishable[resort.slug]
  end
end
