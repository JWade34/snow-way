class Resort < ApplicationRecord
  DATA_FILE = Rails.root.join("db/resorts.yml")

  # Next 7 days, today included.
  def self.forecast_window(as_of = Date.current)
    as_of..(as_of + 6)
  end

  AIRPORTS = {
    "ABQ" => "Albuquerque International Sunport", "ALB" => "Albany International",
    "ANC" => "Ted Stevens Anchorage International", "ASE" => "Aspen/Pitkin County",
    "BLI" => "Bellingham International", "BOI" => "Boise Airport",
    "BTV" => "Burlington International", "BZN" => "Bozeman Yellowstone International",
    "CDC" => "Cedar City Regional", "DEN" => "Denver International",
    "DRO" => "Durango–La Plata County", "EAT" => "Pangborn Memorial (Wenatchee)",
    "EGE" => "Eagle County Regional", "FCA" => "Glacier Park International",
    "FLG" => "Flagstaff Pulliam", "GEG" => "Spokane International",
    "GUC" => "Gunnison–Crested Butte Regional", "HDN" => "Yampa Valley Regional",
    "JAC" => "Jackson Hole Airport", "LWB" => "Greenbrier Valley",
    "MHT" => "Manchester–Boston Regional", "MMH" => "Mammoth Yosemite",
    "ONT" => "Ontario International", "PDX" => "Portland International",
    "PWM" => "Portland International Jetport", "RDM" => "Roberts Field (Redmond)",
    "RNO" => "Reno–Tahoe International", "SAF" => "Santa Fe Regional",
    "SEA" => "Seattle–Tacoma International", "SLC" => "Salt Lake City International",
    "SUN" => "Friedman Memorial (Sun Valley)", "TEX" => "Telluride Regional",
    "YCG" => "West Kootenay Regional (Castlegar)", "YKA" => "Kamloops Airport",
    "YLW" => "Kelowna International", "YQB" => "Québec City Jean Lesage International",
    "YUL" => "Montréal–Trudeau International", "YVR" => "Vancouver International",
    "YXC" => "Canadian Rockies International (Cranbrook)", "YYC" => "Calgary International"
  }.freeze

  has_many :snow_forecasts, dependent: :destroy

  validates :name, :slug, :latitude, :longitude, :nearest_airport_code, presence: true
  validates :slug, uniqueness: true

  # Upserts every resort in db/resorts.yml by slug. Returns the resorts that were newly created.
  def self.sync_from_data_file!(path = DATA_FILE)
    YAML.load_file(path).filter_map do |attrs|
      resort = find_or_initialize_by(slug: attrs.fetch("slug"))
      created = resort.new_record?
      resort.update!(attrs)
      resort if created
    end
  end

  # { resort_id => inches } projected over the forecast window, for every resort with forecast rows.
  def self.projected_totals(as_of = Date.current)
    SnowForecast.where(forecast_date: forecast_window(as_of))
      .group(:resort_id).sum(:snowfall_inches)
      .transform_values { |v| v.to_f.round(1) }
  end

  # Use slug in URLs instead of id
  def to_param
    slug
  end

  def airport_name
    AIRPORTS.fetch(nearest_airport_code, nearest_airport_code)
  end

  def vertical_drop
    elevation_summit - elevation_base if elevation_summit && elevation_base
  end

  def location
    [ state_province, country ].compact.join(", ")
  end

  # Most recent time the forecast rows for this resort were written.
  def forecast_updated_at
    snow_forecasts.maximum(:created_at)
  end

  # Get total projected snowfall for next 7 days
  def projected_snowfall_7_day
    snow_forecasts
      .where(forecast_date: Resort.forecast_window)
      .sum(:snowfall_inches)
      .to_f
      .round(1)
  end

  # Get total snowfall from past 48 hours (yesterday and day before)
  def recent_snowfall_48h
    snow_forecasts
      .where(forecast_date: 2.days.ago.to_date..Date.yesterday)
      .sum(:snowfall_inches)
      .to_f
      .round(1)
  end

  # Scope to order by most snow projected
  scope :by_most_snow, -> {
    left_joins(:snow_forecasts)
      .where(snow_forecasts: { forecast_date: Resort.forecast_window })
      .group(:id)
      .order(Arel.sql("COALESCE(SUM(snow_forecasts.snowfall_inches), 0) DESC"))
  }

  # Scope to order by most recent snowfall (past 48 hours)
  scope :by_recent_snow, -> {
    left_joins(:snow_forecasts)
      .where(snow_forecasts: { forecast_date: 2.days.ago.to_date..Date.yesterday })
      .group(:id)
      .order(Arel.sql("COALESCE(SUM(snow_forecasts.snowfall_inches), 0) DESC"))
  }

  # Get top resort by projected snowfall
  def self.top_powder_destination
    by_most_snow.first
  end
end
