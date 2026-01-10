require "net/http"
require "json"

module SnowForecastable
  extend ActiveSupport::Concern

  class_methods do
    def fetch_forecasts_from_api(resort)
      return [] unless resort

      # Convert summit elevation from feet to meters for Open-Meteo
      summit_meters = (resort.elevation_summit.to_f * 0.3048).round

      uri = URI("https://api.open-meteo.com/v1/forecast")
      uri.query = URI.encode_www_form(
        latitude: resort.latitude,
        longitude: resort.longitude,
        elevation: summit_meters,
        daily: "precipitation_sum,temperature_2m_mean",
        timezone: "auto",
        forecast_days: 7
      )

      response = Net::HTTP.get_response(uri)
      return [] unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      daily = data["daily"]

      return [] unless daily && daily["time"] && daily["precipitation_sum"]

      daily["time"].each_with_index.map do |date_str, i|
        precip_mm = daily["precipitation_sum"][i] || 0
        temp_c = daily["temperature_2m_mean"][i] || 0

        {
          forecast_date: Date.parse(date_str),
          snowfall_inches: calculate_snowfall(precip_mm, temp_c)
        }
      end
    rescue StandardError => e
      Rails.logger.error "Snow forecast fetch failed for #{resort&.name}: #{e.message}"
      []
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

      # Delete old forecasts for this resort
      resort.snow_forecasts.where(forecast_date: Date.today..).delete_all

      # Insert new forecasts
      forecasts.each do |forecast_data|
        resort.snow_forecasts.find_or_create_by(forecast_date: forecast_data[:forecast_date]) do |f|
          f.snowfall_inches = forecast_data[:snowfall_inches]
        end
      end

      Rails.logger.info "Updated forecasts for #{resort.name}: #{forecasts.sum { |f| f[:snowfall_inches] }}\" total"
    end
  end
end
