require "net/http"
require "json"

module SnowForecastable
  extend ActiveSupport::Concern

  class_methods do
    # One request returns two points: mid-mountain (the headline number) and the summit.
    def fetch_forecasts_from_api(resort)
      return [] unless resort

      mid_meters = (resort.mid_elevation.to_f * 0.3048).round
      summit_meters = (resort.elevation_summit.to_f * 0.3048).round

      uri = URI("https://api.open-meteo.com/v1/forecast")
      uri.query = URI.encode_www_form(
        latitude: [ resort.latitude, resort.latitude ].join(","),
        longitude: [ resort.longitude, resort.longitude ].join(","),
        elevation: [ mid_meters, summit_meters ].join(","),
        daily: "precipitation_sum,temperature_2m_mean,snowfall_sum,temperature_2m_max,temperature_2m_min,weather_code,wind_speed_10m_max",
        current: "temperature_2m,wind_speed_10m,weather_code",
        timezone: "auto",
        forecast_days: 16,
        past_days: 2
      )

      response = Net::HTTP.get_response(uri)
      return [] unless response.is_a?(Net::HTTPSuccess)

      mid, summit = JSON.parse(response.body)
      return [] unless mid.is_a?(Hash) && summit.is_a?(Hash)

      store_current_conditions(resort, mid["current"])
      mid_days = daily_snowfall(mid["daily"])
      summit_days = daily_snowfall(summit["daily"]).to_h { |d| [ d[:forecast_date], d[:snowfall_inches] ] }
      mid_days.map { |day| day.merge(snowfall_summit_inches: summit_days[day[:forecast_date]]) }
    rescue StandardError => e
      Rails.logger.error "Snow forecast fetch failed for #{resort&.name}: #{e.message}"
      []
    end

    def daily_snowfall(daily)
      return [] unless daily && daily["time"] && daily["precipitation_sum"]

      daily["time"].each_with_index.map do |date_str, i|
        # Prefer snowfall_sum from API (in cm), fall back to calculation
        snowfall_cm = daily["snowfall_sum"]&.dig(i)
        if snowfall_cm && snowfall_cm > 0
          snowfall_inches = (snowfall_cm * 0.393701).round(1)
        else
          precip_mm = daily["precipitation_sum"][i] || 0
          temp_c = daily["temperature_2m_mean"][i] || 0
          snowfall_inches = calculate_snowfall(precip_mm, temp_c)
        end

        {
          forecast_date: Date.parse(date_str),
          snowfall_inches: snowfall_inches,
          temp_high_f: c_to_f(daily["temperature_2m_max"]&.dig(i)),
          temp_low_f: c_to_f(daily["temperature_2m_min"]&.dig(i)),
          weather_code: daily["weather_code"]&.dig(i),
          wind_max_mph: daily["wind_speed_10m_max"]&.dig(i)&.then { |kmh| (kmh * 0.621371).round }
        }
      end
    end

    def c_to_f(celsius)
      (celsius * 9.0 / 5 + 32).round if celsius
    end

    # Mid-mountain conditions at fetch time; skipped quietly if the API omits them.
    def store_current_conditions(resort, current)
      return unless current && resort.persisted?

      resort.update_columns(
        current_temp_f: c_to_f(current["temperature_2m"]),
        current_wind_mph: (current["wind_speed_10m"] * 0.621371).round,
        current_weather_code: current["weather_code"],
        conditions_at: Time.current
      )
    rescue StandardError => e
      Rails.logger.error "Storing conditions failed for #{resort.name}: #{e.message}"
    end

    # Calculate snowfall from precipitation using temperature-based snow:water ratio
    # Cold temps produce lighter, fluffier snow (higher ratio)
    def calculate_snowfall(precip_mm, temp_c)
      return 0.0 if precip_mm <= 0 || temp_c > 2 # No snow if warm

      # Snow:water ratio based on temperature (mountain snowfall tends to be drier)
      ratio = case temp_c
      when ..-15 then 18  # Very cold = very dry powder
      when -15..-10 then 15 # Cold = dry powder
      when -10..-5 then 12  # Cool = powder
      when -5..0 then 10    # Near freezing = average
      else 8                # Just below freezing = wet snow
      end

      # Convert: mm of water -> cm of snow -> inches
      # precip_mm * (ratio / 10) = cm of snow
      snow_cm = precip_mm * (ratio / 10.0)
      (snow_cm * 0.393701).round(1)
    end

    def refresh_all_forecasts!
      Resort.find_each do |resort|
        refresh_forecasts_for!(resort)
        sleep 0.1 # Rate limiting
      end
    end

    def refresh_forecasts_for!(resort)
      forecasts = fetch_forecasts_from_api(resort)
      return if forecasts.empty?

      # Delete forecasts from 2 days ago through future (covers past + forecast window)
      resort.snow_forecasts.where(forecast_date: 2.days.ago.to_date..).delete_all

      # Insert all forecasts (past and future)
      forecasts.each do |forecast_data|
        resort.snow_forecasts.create!(forecast_data)
      end

      Rails.logger.info "Updated forecasts for #{resort.name}: #{forecasts.sum { |f| f[:snowfall_inches] }}\" total"
    end
  end
end
