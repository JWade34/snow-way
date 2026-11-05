# Resorts live in db/resorts.yml (shared with `bin/rails resorts:sync`).
puts "Seeding resorts from db/resorts.yml..."
Resort.sync_from_data_file!
puts "Done! Created #{Resort.count} resorts."

# Sample forecasts are for local development only; production pulls real data from Open-Meteo.
return if Rails.env.production?

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
