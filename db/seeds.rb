# North American Ski Resorts
# Data includes coordinates, nearest airports, and elevation

resorts = [
  # Colorado
  { name: "Vail", slug: "vail", latitude: 39.6403, longitude: -106.3742, nearest_airport_code: "EGE", state_province: "Colorado", country: "USA", elevation_base: 8120, elevation_summit: 11570, website_url: "https://www.vail.com" },
  { name: "Breckenridge", slug: "breckenridge", latitude: 39.4817, longitude: -106.0384, nearest_airport_code: "DEN", state_province: "Colorado", country: "USA", elevation_base: 9600, elevation_summit: 12998, website_url: "https://www.breckenridge.com" },
  { name: "Aspen Snowmass", slug: "aspen-snowmass", latitude: 39.2084, longitude: -106.9490, nearest_airport_code: "ASE", state_province: "Colorado", country: "USA", elevation_base: 8104, elevation_summit: 12510, website_url: "https://www.aspensnowmass.com" },
  { name: "Telluride", slug: "telluride", latitude: 37.9375, longitude: -107.8123, nearest_airport_code: "TEX", state_province: "Colorado", country: "USA", elevation_base: 8725, elevation_summit: 13150, website_url: "https://www.tellurideskiresort.com" },
  { name: "Steamboat", slug: "steamboat", latitude: 40.4572, longitude: -106.8045, nearest_airport_code: "HDN", state_province: "Colorado", country: "USA", elevation_base: 6900, elevation_summit: 10568, website_url: "https://www.steamboat.com" },
  { name: "Winter Park", slug: "winter-park", latitude: 39.8868, longitude: -105.7625, nearest_airport_code: "DEN", state_province: "Colorado", country: "USA", elevation_base: 9000, elevation_summit: 12060, website_url: "https://www.winterparkresort.com" },

  # Utah
  { name: "Park City", slug: "park-city", latitude: 40.6514, longitude: -111.5080, nearest_airport_code: "SLC", state_province: "Utah", country: "USA", elevation_base: 6900, elevation_summit: 10026, website_url: "https://www.parkcitymountain.com" },
  { name: "Alta", slug: "alta", latitude: 40.5884, longitude: -111.6386, nearest_airport_code: "SLC", state_province: "Utah", country: "USA", elevation_base: 8530, elevation_summit: 10550, website_url: "https://www.alta.com" },
  { name: "Snowbird", slug: "snowbird", latitude: 40.5830, longitude: -111.6556, nearest_airport_code: "SLC", state_province: "Utah", country: "USA", elevation_base: 7760, elevation_summit: 11000, website_url: "https://www.snowbird.com" },
  { name: "Deer Valley", slug: "deer-valley", latitude: 40.6375, longitude: -111.4783, nearest_airport_code: "SLC", state_province: "Utah", country: "USA", elevation_base: 6570, elevation_summit: 9570, website_url: "https://www.deervalley.com" },
  { name: "Brighton", slug: "brighton", latitude: 40.5980, longitude: -111.5832, nearest_airport_code: "SLC", state_province: "Utah", country: "USA", elevation_base: 8755, elevation_summit: 10500, website_url: "https://www.brightonresort.com" },

  # California
  { name: "Mammoth Mountain", slug: "mammoth-mountain", latitude: 37.6308, longitude: -119.0326, nearest_airport_code: "MMH", state_province: "California", country: "USA", elevation_base: 7953, elevation_summit: 11053, website_url: "https://www.mammothmountain.com" },
  { name: "Palisades Tahoe", slug: "palisades-tahoe", latitude: 39.1970, longitude: -120.2358, nearest_airport_code: "RNO", state_province: "California", country: "USA", elevation_base: 6200, elevation_summit: 9050, website_url: "https://www.palisadestahoe.com" },
  { name: "Heavenly", slug: "heavenly", latitude: 38.9353, longitude: -119.9400, nearest_airport_code: "RNO", state_province: "California", country: "USA", elevation_base: 6540, elevation_summit: 10067, website_url: "https://www.skiheavenly.com" },
  { name: "Northstar", slug: "northstar", latitude: 39.2746, longitude: -120.1210, nearest_airport_code: "RNO", state_province: "California", country: "USA", elevation_base: 6330, elevation_summit: 8610, website_url: "https://www.northstarcalifornia.com" },
  { name: "Kirkwood", slug: "kirkwood", latitude: 38.6850, longitude: -120.0652, nearest_airport_code: "RNO", state_province: "California", country: "USA", elevation_base: 7800, elevation_summit: 9800, website_url: "https://www.kirkwood.com" },

  # Wyoming
  { name: "Jackson Hole", slug: "jackson-hole", latitude: 43.5875, longitude: -110.8279, nearest_airport_code: "JAC", state_province: "Wyoming", country: "USA", elevation_base: 6311, elevation_summit: 10450, website_url: "https://www.jacksonhole.com" },
  { name: "Grand Targhee", slug: "grand-targhee", latitude: 43.7872, longitude: -110.9585, nearest_airport_code: "JAC", state_province: "Wyoming", country: "USA", elevation_base: 8000, elevation_summit: 10230, website_url: "https://www.grandtarghee.com" },

  # Montana
  { name: "Big Sky", slug: "big-sky", latitude: 45.2858, longitude: -111.4018, nearest_airport_code: "BZN", state_province: "Montana", country: "USA", elevation_base: 7500, elevation_summit: 11166, website_url: "https://www.bigskyresort.com" },
  { name: "Whitefish Mountain", slug: "whitefish-mountain", latitude: 48.4827, longitude: -114.3506, nearest_airport_code: "FCA", state_province: "Montana", country: "USA", elevation_base: 4464, elevation_summit: 6817, website_url: "https://www.skiwhitefish.com" },

  # Idaho
  { name: "Sun Valley", slug: "sun-valley", latitude: 43.6777, longitude: -114.3507, nearest_airport_code: "SUN", state_province: "Idaho", country: "USA", elevation_base: 5750, elevation_summit: 9150, website_url: "https://www.sunvalley.com" },

  # New Mexico
  { name: "Taos Ski Valley", slug: "taos-ski-valley", latitude: 36.5958, longitude: -105.4542, nearest_airport_code: "ABQ", state_province: "New Mexico", country: "USA", elevation_base: 9207, elevation_summit: 12481, website_url: "https://www.skitaos.com" },

  # Vermont
  { name: "Stowe", slug: "stowe", latitude: 44.5303, longitude: -72.7814, nearest_airport_code: "BTV", state_province: "Vermont", country: "USA", elevation_base: 1559, elevation_summit: 3719, website_url: "https://www.stowe.com" },
  { name: "Killington", slug: "killington", latitude: 43.6045, longitude: -72.8201, nearest_airport_code: "BTV", state_province: "Vermont", country: "USA", elevation_base: 1165, elevation_summit: 4241, website_url: "https://www.killington.com" },
  { name: "Sugarbush", slug: "sugarbush", latitude: 44.1357, longitude: -72.9014, nearest_airport_code: "BTV", state_province: "Vermont", country: "USA", elevation_base: 1483, elevation_summit: 4083, website_url: "https://www.sugarbush.com" },

  # Canada - British Columbia
  { name: "Whistler Blackcomb", slug: "whistler-blackcomb", latitude: 50.1163, longitude: -122.9574, nearest_airport_code: "YVR", state_province: "British Columbia", country: "Canada", elevation_base: 2140, elevation_summit: 7494, website_url: "https://www.whistlerblackcomb.com" },
  { name: "Revelstoke", slug: "revelstoke", latitude: 51.0045, longitude: -118.1640, nearest_airport_code: "YLW", state_province: "British Columbia", country: "Canada", elevation_base: 1680, elevation_summit: 7300, website_url: "https://www.revelstokemountainresort.com" },
  { name: "Big White", slug: "big-white", latitude: 49.7216, longitude: -118.9325, nearest_airport_code: "YLW", state_province: "British Columbia", country: "Canada", elevation_base: 4950, elevation_summit: 7606, website_url: "https://www.bigwhite.com" },
  { name: "Sun Peaks", slug: "sun-peaks", latitude: 50.8833, longitude: -119.8833, nearest_airport_code: "YKA", state_province: "British Columbia", country: "Canada", elevation_base: 3960, elevation_summit: 7060, website_url: "https://www.sunpeaksresort.com" },

  # Canada - Alberta
  { name: "Lake Louise", slug: "lake-louise", latitude: 51.4254, longitude: -116.1773, nearest_airport_code: "YYC", state_province: "Alberta", country: "Canada", elevation_base: 5400, elevation_summit: 8650, website_url: "https://www.skilouise.com" },
  { name: "Banff Sunshine", slug: "banff-sunshine", latitude: 51.1150, longitude: -115.7634, nearest_airport_code: "YYC", state_province: "Alberta", country: "Canada", elevation_base: 5440, elevation_summit: 8954, website_url: "https://www.skibanff.com" },
  { name: "Kicking Horse", slug: "kicking-horse", latitude: 51.2975, longitude: -117.0478, nearest_airport_code: "YYC", state_province: "Alberta", country: "Canada", elevation_base: 3900, elevation_summit: 8033, website_url: "https://kickinghorseresort.com" },

  # Canada - Quebec
  { name: "Mont Tremblant", slug: "mont-tremblant", latitude: 46.2094, longitude: -74.5850, nearest_airport_code: "YUL", state_province: "Quebec", country: "Canada", elevation_base: 870, elevation_summit: 2871, website_url: "https://www.tremblant.ca" },

  # Oregon
  { name: "Mt. Bachelor", slug: "mt-bachelor", latitude: 43.9792, longitude: -121.6889, nearest_airport_code: "RDM", state_province: "Oregon", country: "USA", elevation_base: 5700, elevation_summit: 9068, website_url: "https://www.mtbachelor.com" },

  # Washington
  { name: "Crystal Mountain", slug: "crystal-mountain", latitude: 46.9282, longitude: -121.5045, nearest_airport_code: "SEA", state_province: "Washington", country: "USA", elevation_base: 4400, elevation_summit: 7002, website_url: "https://www.crystalmountainresort.com" },
  { name: "Stevens Pass", slug: "stevens-pass", latitude: 47.7448, longitude: -121.0890, nearest_airport_code: "SEA", state_province: "Washington", country: "USA", elevation_base: 4061, elevation_summit: 5845, website_url: "https://www.stevenspass.com" },

  # Alaska
  { name: "Alyeska", slug: "alyeska", latitude: 60.9689, longitude: -149.0981, nearest_airport_code: "ANC", state_province: "Alaska", country: "USA", elevation_base: 250, elevation_summit: 2750, website_url: "https://www.alyeskaresort.com" }
]

puts "Seeding #{resorts.count} resorts..."

resorts.each do |resort_data|
  Resort.find_or_create_by!(slug: resort_data[:slug]) do |resort|
    resort.assign_attributes(resort_data)
  end
end

puts "Done! Created #{Resort.count} resorts."

# Add sample snow forecasts for demo purposes
puts "Adding sample snow forecasts..."

Resort.find_each do |resort|
  # Generate 7 days of forecasts with random snowfall
  # Higher elevation resorts tend to get more snow
  base_snow = (resort.elevation_summit.to_f / 1000).round(1)

  7.times do |i|
    forecast_date = Date.today + i.days

    # Random variation - some days get dumps, some are dry
    variation = rand(0.0..3.0).round(1)
    snowfall = (base_snow * variation * rand(0.0..1.5)).round(1)

    resort.snow_forecasts.find_or_create_by!(forecast_date: forecast_date) do |forecast|
      forecast.snowfall_inches = snowfall
      forecast.fetched_at = Time.current
    end
  end
end

puts "Done! Created #{SnowForecast.count} snow forecasts."
puts ""
puts "Top 5 powder destinations:"
Resort.by_most_snow.limit(5).each_with_index do |resort, i|
  puts "#{i + 1}. #{resort.name}: #{resort.projected_snowfall_7_day}\" projected"
end
