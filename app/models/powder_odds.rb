# Share of days with 1"+ of fresh snow, by ski-season month. A frequency, not an inch total. Two measured sources:
# - measured: USDA NRCS SNOTEL snow stations near mid-mountain (db/station_odds.yml from bin/rails resorts:station_odds,
#   stations hand-picked in db/snow_stations.yml; only "good" and "ok" matches are used). Western US only.
# - weather: NOAA ACIS daily snowfall from co-op, CoCoRaHS and Environment Canada observers, mostly at the base or in
#   the valley (db/weather_station_odds.yml from bin/rails resorts:weather_station_odds, stations in db/weather_stations.yml).
# The two are measured differently and at different heights, so a ranking never mixes them. Resorts with neither get
# no number: the old Open-Meteo/ERA5 model (db/powder_odds.yml) undercounts mountain snow and is no longer shown.
module PowderOdds
  FILE = Rails.root.join("db/powder_odds.yml")
  MEASURED_FILE = Rails.root.join("db/station_odds.yml")
  STATIONS_FILE = Rails.root.join("db/snow_stations.yml")
  WEATHER_FILE = Rails.root.join("db/weather_station_odds.yml")
  WEATHER_STATIONS_FILE = Rails.root.join("db/weather_stations.yml")
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

  def weather_data
    @weather_data = nil if Rails.env.development?
    @weather_data ||= load(WEATHER_FILE)
  end

  def weather_stations
    @weather_stations = nil if Rails.env.development?
    @weather_stations ||= load(WEATHER_STATIONS_FILE).fetch("resorts", {})
  end

  # Modeled odds (Open-Meteo/ERA5). Kept for reference only; never shown on the site.
  def for(resort)
    odds = data.dig("resorts", resort.slug) or return
    resort.ski_season_months.to_h { |m| [ m, odds[m].to_i ] }
  end

  # The NOAA weather station for a resort with no SNOTEL station ({ "name", "miles", "elev", ... }), or nil.
  def weather_station(resort)
    return if station(resort)
    st = weather_stations[resort.slug]
    st if st.is_a?(Hash) && USABLE.include?(st["quality"]) && weather_data.dig("resorts", resort.slug)
  end

  # Measured odds at the NOAA weather station, in season order, or nil.
  def weather(resort)
    weather_station(resort) or return
    odds = weather_data.dig("resorts", resort.slug, "odds") or return
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

  # Best available odds for one resort's own page: [odds, :measured | :weather], or nil when nothing measured exists.
  def best(resort)
    (o = measured(resort)) ? [ o, :measured ] : ((o = weather(resort)) ? [ o, :weather ] : nil)
  end

  # The station behind best(resort), or nil.
  def any_station(resort) = station(resort) || weather_station(resort)

  def source = data["source"]
  def measured_source = measured_data["source"]
  def weather_source = weather_data["source"]
end
