# Resort-reported average annual snowfall with a source per resort (db/average_snowfall.yml).
# Modeled weather data undercounts mountain snow, so only these sourced numbers are published as inch totals.
module AverageSnowfall
  FILE = Rails.root.join("db/average_snowfall.yml")

  module_function

  def data
    @data = nil if Rails.env.development?
    @data ||= File.exist?(FILE) ? YAML.load_file(FILE, permitted_classes: [ Date ]) : { "resorts" => {} }
  end

  def checked_on
    data["checked_on"]
  end

  # { "alta" => { "inches" => 546, "source" => ..., "publisher" => ..., "note" => ... } }
  def all
    data.fetch("resorts", {}) || {}
  end

  def for(resort)
    all[resort.slug]
  end
end
