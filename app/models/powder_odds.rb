# Share of days with 1"+ of fresh snow, by ski-season month. A frequency, not an inch total. Two sources:
# - measured: USDA NRCS SNOTEL stations near the resort (db/station_odds.yml from bin/rails resorts:station_odds,
#   stations hand-picked in db/snow_stations.yml; only "good" and "ok" matches are used).
# - model: 10 seasons of Open-Meteo history at mid-mountain (db/powder_odds.yml from bin/rails resorts:powder_odds).
# Measured days run about 1.4x the model's, so a single ranking must never mix the two.
module PowderOdds
  FILE = Rails.root.join("db/powder_odds.yml")
  MEASURED_FILE = Rails.root.join("db/station_odds.yml")
  STATIONS_FILE = Rails.root.join("db/snow_stations.yml")
  USABLE = %w[good ok].freeze

  module_function

  def load(path) = File.exist?(path) ? YAML.load_file(path) : {}

  def data
    @data = nil if Rails.env.development?
    @data ||= load(FILE)
  end

  def measured_data
    @measured_data = nil if Rails.env.development?
    @measured_data ||= load(MEASURED_FILE)
  end

  def stations
    @stations = nil if Rails.env.development?
    @stations ||= load(STATIONS_FILE).fetch("resorts", {})
  end

  # Modeled odds: { 12 => 24, 1 => 29, ... } in season order, or nil.
  def for(resort)
    odds = data.dig("resorts", resort.slug) or return
    resort.ski_season_months.to_h { |m| [ m, odds[m].to_i ] }
  end

  # The approved SNOTEL station for a resort ({ "name", "miles", "elev", ... }), or nil.
  def station(resort)
    st = stations[resort.slug]
    st if st.is_a?(Hash) && USABLE.include?(st["quality"]) && measured_data.dig("resorts", resort.slug)
  end

  # Measured odds in season order, or nil when the resort has no approved station.
  def measured(resort)
    station(resort) or return
    odds = measured_data.dig("resorts", resort.slug, "odds") or return
    resort.ski_season_months.to_h { |m| [ m, odds[m].to_i ] }
  end

  # Best available odds for one resort's own page: [odds, :measured | :model], or nil.
  def best(resort)
    (o = measured(resort)) ? [ o, :measured ] : ((o = self.for(resort)) ? [ o, :model ] : nil)
  end

  def source = data["source"]
  def measured_source = measured_data["source"]
end
