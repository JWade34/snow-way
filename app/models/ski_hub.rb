# Cities skiers fly into or live near. Powers /ski-resorts-near/:slug pages.
# Distances are straight-line from the city's main airport, not drive distance.
class SkiHub
  RADIUS_MILES = 200
  MIN_RESORTS = 3

  HUBS = [
    { slug: "denver", city: "Denver", airport: "DEN", lat: 39.8561, lon: -104.6737 },
    { slug: "salt-lake-city", city: "Salt Lake City", airport: "SLC", lat: 40.7899, lon: -111.9791 },
    { slug: "reno-lake-tahoe", city: "Reno & Lake Tahoe", airport: "RNO", lat: 39.4991, lon: -119.7681 },
    { slug: "seattle", city: "Seattle", airport: "SEA", lat: 47.4502, lon: -122.3088 },
    { slug: "portland", city: "Portland, Oregon", airport: "PDX", lat: 45.5898, lon: -122.5951 },
    { slug: "boise", city: "Boise", airport: "BOI", lat: 43.5644, lon: -116.2228 },
    { slug: "bozeman", city: "Bozeman", airport: "BZN", lat: 45.7775, lon: -111.1530 },
    { slug: "boston", city: "Boston", airport: "BOS", lat: 42.3656, lon: -71.0096 },
    { slug: "new-york-city", city: "New York City", airport: "JFK", lat: 40.6413, lon: -73.7781 },
    { slug: "albany", city: "Albany", airport: "ALB", lat: 42.7483, lon: -73.8017 },
    { slug: "burlington", city: "Burlington, Vermont", airport: "BTV", lat: 44.4719, lon: -73.1533 },
    { slug: "portland-maine", city: "Portland, Maine", airport: "PWM", lat: 43.6462, lon: -70.3093 },
    { slug: "montreal", city: "Montreal", airport: "YUL", lat: 45.4706, lon: -73.7408 },
    { slug: "quebec-city", city: "Quebec City", airport: "YQB", lat: 46.7911, lon: -71.3933 },
    { slug: "vancouver", city: "Vancouver", airport: "YVR", lat: 49.1967, lon: -123.1815 },
    { slug: "calgary", city: "Calgary", airport: "YYC", lat: 51.1215, lon: -114.0076 },
    { slug: "spokane", city: "Spokane", airport: "GEG", lat: 47.6199, lon: -117.5338 },
    { slug: "albuquerque-santa-fe", city: "Albuquerque & Santa Fe", airport: "ABQ", lat: 35.0402, lon: -106.6090 },
    { slug: "los-angeles", city: "Los Angeles", airport: "LAX", lat: 33.9416, lon: -118.4085 },
    { slug: "las-vegas", city: "Las Vegas", airport: "LAS", lat: 36.0840, lon: -115.1537 },
    { slug: "sacramento", city: "Sacramento", airport: "SMF", lat: 38.6954, lon: -121.5908 },
    { slug: "philadelphia", city: "Philadelphia", airport: "PHL", lat: 39.8744, lon: -75.2424 },
    { slug: "pittsburgh", city: "Pittsburgh", airport: "PIT", lat: 40.4915, lon: -80.2329 },
    { slug: "washington-dc", city: "Washington, D.C.", airport: "IAD", lat: 38.9531, lon: -77.4565 },
    { slug: "chicago", city: "Chicago", airport: "ORD", lat: 41.9742, lon: -87.9073 },
    { slug: "minneapolis", city: "Minneapolis", airport: "MSP", lat: 44.8848, lon: -93.2223 },
    { slug: "detroit", city: "Detroit", airport: "DTW", lat: 42.2162, lon: -83.3554 },
    { slug: "cleveland", city: "Cleveland", airport: "CLE", lat: 41.4058, lon: -81.8539 },
    { slug: "toronto", city: "Toronto", airport: "YYZ", lat: 43.6777, lon: -79.6248 },
    { slug: "charlotte", city: "Charlotte", airport: "CLT", lat: 35.2144, lon: -80.9473 },
    { slug: "atlanta", city: "Atlanta", airport: "ATL", lat: 33.6407, lon: -84.4277 },
    { slug: "edmonton", city: "Edmonton", airport: "YEG", lat: 53.3097, lon: -113.5800 }
  ].freeze

  attr_reader :slug, :city, :airport, :lat, :lon

  def self.all(resorts = Resort.north_america.to_a)
    HUBS.map { |h| new(**h, resorts: resorts) }.select { |hub| hub.nearby.size >= MIN_RESORTS }
  end

  def self.find(slug)
    all.find { |h| h.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  def initialize(slug:, city:, airport:, lat:, lon:, resorts:)
    @slug, @city, @airport, @lat, @lon, @resorts = slug, city, airport, lat, lon, resorts
  end

  def to_param
    slug
  end

  # [[resort, miles], ...] within RADIUS_MILES, nearest first.
  def nearby
    @nearby ||= @resorts.map { |r| [ r, self.class.miles_between(lat, lon, r.latitude.to_f, r.longitude.to_f) ] }
      .select { |_, miles| miles <= RADIUS_MILES }
      .sort_by { |_, miles| miles }
  end

  # Estimated driving time and road distance from db/drive_times.yml: { "minutes" => 70, "miles" => 54 } or nil.
  def drive(resort)
    self.class.drive_times.dig("hubs", slug, resort.slug)
  end

  def self.drive_times
    @drive_times = nil if Rails.env.development?
    @drive_times ||= begin
      file = Rails.root.join("db/drive_times.yml")
      File.exist?(file) ? YAML.load_file(file) : {}
    end
  end

  def self.miles_between(lat1, lon1, lat2, lon2)
    rad = Math::PI / 180
    dlat = (lat2 - lat1) * rad
    dlon = (lon2 - lon1) * rad
    a = Math.sin(dlat / 2)**2 + Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin(dlon / 2)**2
    (3958.8 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))).round
  end
end
