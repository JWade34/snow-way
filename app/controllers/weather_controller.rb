class WeatherController < ApplicationController
  def index
    @resorts = Resort.by_most_snow.limit(10)
    @weather_data = WeatherData.fetch_for_resorts(@resorts)
  end

  def refresh
    Resort.find_each do |resort|
      begin
        SnowForecast.refresh_forecasts_for!(resort)
      rescue => e
        Rails.logger.error "Failed to refresh forecasts for #{resort.name}: #{e.message}"
      end
      sleep 0.2
    end

    redirect_to resorts_path, notice: "Forecasts refreshed successfully!"
  end
end
