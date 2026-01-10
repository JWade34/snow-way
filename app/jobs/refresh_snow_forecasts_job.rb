class RefreshSnowForecastsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting snow forecast refresh..."

    Resort.find_each do |resort|
      begin
        SnowForecast.refresh_forecasts_for!(resort)
      rescue => e
        Rails.logger.error "Failed to refresh forecasts for #{resort.name}: #{e.message}"
      end

      # Rate limiting - Open-Meteo allows 10,000 requests/day
      sleep 0.2
    end

    Rails.logger.info "Snow forecast refresh complete!"
  end
end
