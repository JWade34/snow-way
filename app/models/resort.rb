class Resort < ApplicationRecord
  DATA_FILE = Rails.root.join("db/resorts.yml")
  FACTS_FILE = Rails.root.join("db/resort_facts.yml")
  PASS_LABELS = {
    "epic" => "Epic Pass", "ikon" => "Ikon Pass", "both" => "Epic & Ikon",
    "independent" => "Independent"
  }.freeze

  # Next `days` days, today included.
  def self.forecast_window(as_of = Date.current, days: 7)
    as_of..(as_of + days - 1)
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
    "YXC" => "Canadian Rockies International (Cranbrook)", "YYC" => "Calgary International",
"ABE" => "Lehigh Valley International",
    "AVL" => "Asheville Regional",
    "AVP" => "Wilkes-Barre/Scranton International",
    "BIL" => "Billings Logan International",
    "BUF" => "Buffalo Niagara International",
    "CHO" => "Charlottesville–Albemarle",
    "CKB" => "North Central West Virginia",
    "CLE" => "Cleveland Hopkins International",
    "CMX" => "Houghton County Memorial",
    "CVG" => "Cincinnati/Northern Kentucky International",
    "CWA" => "Central Wisconsin (Mosinee)",
    "DAY" => "Dayton International",
    "DLH" => "Duluth International",
    "ELP" => "El Paso International",
    "EWR" => "Newark Liberty International",
    "FAT" => "Fresno Yosemite International",
    "GJT" => "Grand Junction Regional",
    "IAD" => "Washington Dulles International",
    "LAS" => "Harry Reid International (Las Vegas)",
    "MDT" => "Harrisburg International",
    "MFR" => "Rogue Valley International–Medford",
    "MKE" => "Milwaukee Mitchell International",
    "MSO" => "Missoula Montana",
    "MSP" => "Minneapolis–Saint Paul International",
    "PIT" => "Pittsburgh International",
    "PLN" => "Pellston Regional",
    "RAP" => "Rapid City Regional",
    "SDF" => "Louisville Muhammad Ali International",
    "SMF" => "Sacramento International",
    "SYR" => "Syracuse Hancock International",
    "TRI" => "Tri-Cities (Tennessee)",
    "TVC" => "Cherry Capital (Traverse City)",
    "TYS" => "McGhee Tyson (Knoxville)",
    "YEG" => "Edmonton International",
    "YQL" => "Lethbridge",
    "YQQ" => "Comox Valley",
    "YYF" => "Penticton Regional",
    "YYZ" => "Toronto Pearson International",
    "PHL" => "Philadelphia International",
    "ORD" => "Chicago O'Hare International",
    "DTW" => "Detroit Metropolitan Wayne County",
    "CLT" => "Charlotte Douglas International",
    "ATL" => "Hartsfield–Jackson Atlanta International",
    "LAX" => "Los Angeles International",
    "JFK" => "John F. Kennedy International",
    "BOS" => "Boston Logan International",
    "CTS" => "New Chitose (Sapporo)", "HND" => "Tokyo Haneda",
    "GVA" => "Geneva Airport", "ZRH" => "Zurich Airport", "INN" => "Innsbruck Airport", "VCE" => "Venice Marco Polo",
    "SCL" => "Santiago International (Arturo Merino Benítez)", "CCP" => "Concepción Carriel Sur", "ZCO" => "Temuco La Araucanía",
    "BRC" => "San Carlos de Bariloche", "MDZ" => "Mendoza El Plumerillo", "CPC" => "Chapelco (San Martín de los Andes)",
    "USH" => "Ushuaia International", "CBR" => "Canberra Airport", "ZQN" => "Queenstown Airport", "CHC" => "Christchurch Airport"
  }.freeze

  # Rankings, "North American" wording, opening dates, and the Powder Calendar cover these countries only.
  # Resorts elsewhere get full pages but are grouped by country and ranked separately.
  NA_COUNTRIES = %w[USA Canada].freeze

  has_many :snow_forecasts, dependent: :destroy
  has_one :visit, class_name: "ResortVisit", dependent: :destroy

  scope :north_america, -> { where(country: NA_COUNTRIES) }
  scope :international, -> { where.not(country: NA_COUNTRIES) }

  validates :name, :slug, :latitude, :longitude, :nearest_airport_code, presence: true
  validates :slug, uniqueness: true

  FACT_FIELDS = %w[pass pass_note pass_source other_passes opening_date opening_status opening_source].freeze

  # Upserts every resort in db/resorts.yml by slug, merging sourced facts from db/resort_facts.yml.
  # Returns the resorts that were newly created.
  def self.sync_from_data_file!(path = DATA_FILE, facts_path = FACTS_FILE)
    facts = File.exist?(facts_path) ? YAML.load_file(facts_path, permitted_classes: [ Date ]) : {}
    checked_on = facts["checked_on"]
    resort_facts = facts.fetch("resorts", {}) || {}

    YAML.load_file(path).filter_map do |attrs|
      resort = find_or_initialize_by(slug: attrs.fetch("slug"))
      created = resort.new_record?
      fact = (resort_facts[attrs["slug"]] || {}).slice(*FACT_FIELDS)
      resort.update!(attrs.merge(fact).merge("facts_checked_on" => (checked_on if fact.any?)))
      resort if created
    end
  end

  def self.pass_prices
    facts = File.exist?(FACTS_FILE) ? YAML.load_file(FACTS_FILE, permitted_classes: [ Date ]) : {}
    { checked_on: facts["checked_on"], passes: facts.fetch("passes", {}) || {} }
  end

  # { resort_id => inches } projected over the forecast window, for every resort with forecast rows.
  def self.projected_totals(as_of = Date.current, days: 7)
    SnowForecast.where(forecast_date: forecast_window(as_of, days: days))
      .group(:resort_id).sum(:snowfall_inches)
      .transform_values { |v| v.to_f.round(1) }
  end

  # { resort_id => inches } at the summit over the forecast window.
  def self.projected_summit_totals(as_of = Date.current, days: 7)
    SnowForecast.where(forecast_date: forecast_window(as_of, days: days))
      .group(:resort_id).sum(:snowfall_summit_inches)
      .transform_values { |v| v.to_f.round(1) }
  end

  # { resort_id => inches } over the last 48 hours (the two days before today).
  def self.recent_totals(as_of = Date.current)
    SnowForecast.where(forecast_date: (as_of - 2)..(as_of - 1))
      .group(:resort_id).sum(:snowfall_inches)
      .transform_values { |v| v.to_f.round(1) }
  end

  def north_american?
    NA_COUNTRIES.include?(country)
  end

  def southern_hemisphere?
    latitude.to_f.negative?
  end

  # The directory a resort belongs to: its state or province in North America, its country elsewhere.
  def region_name
    north_american? ? state_province : country
  end

  def region_slug
    region_name.parameterize
  end

  # Resorts in the same directory region.
  def region_peers
    scope = north_american? ? Resort.where(state_province: state_province) : Resort.where(country: country)
    scope.where.not(id: id)
  end

  # Resorts this one is ranked against: North America, or everywhere else.
  def ranking_pool
    north_american? ? Resort.north_america : Resort.international
  end

  def market_label
    north_american? ? "North American" : "international"
  end

  def pass_label
    PASS_LABELS[pass]
  end

  def on_epic?
    %w[epic both].include?(pass)
  end

  def on_ikon?
    %w[ikon both].include?(pass)
  end

  # Months lifts typically run: Nov-May in the north, Jun-Oct in the south.
  def ski_season_months
    southern_hemisphere? ? (6..10).to_a : [ 11, 12, 1, 2, 3, 4, 5 ]
  end

  # Ski-season months ranked by share of a typical season's snowfall (modeled), e.g. [[1, 16.6], [3, 16.7], ...]
  # Shoulder months can model snowy at high summits while lifts are closed, so they're left out.
  def snowiest_months(limit = 3)
    (monthly_snow_share || {}).map { |m, v| [ m.to_i, v.to_f ] }
      .select { |m, _| ski_season_months.include?(m) }
      .sort_by { |_, v| -v }.first(limit)
  end

  # First full month of the season, used for "good snow early?" answers.
  def early_season_month
    southern_hemisphere? ? 6 : 12
  end

  # Use slug in URLs instead of id
  def to_param
    slug
  end

  def airport_name
    AIRPORTS.fetch(nearest_airport_code, nearest_airport_code)
  end

  # Halfway between base and summit: the elevation Snow Way's headline forecast uses.
  def mid_elevation
    ((elevation_base.to_i + elevation_summit.to_i) / 2.0).round
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
    north_america.by_most_snow.first
  end
end
