class RefreshSnowForecastsJob < ApplicationJob
  queue_as :default

  # resort_ids: refresh only these resorts (e.g. newly added ones); nil refreshes all.
  def perform(resort_ids = nil)
    Rails.logger.info "Starting snow forecast refresh..."

    scope = resort_ids ? Resort.where(id: resort_ids) : Resort.all
    scope.find_each do |resort|
      begin
        SnowForecast.refresh_forecasts_for!(resort)
      rescue => e
        Rails.logger.error "Failed to refresh forecasts for #{resort.name}: #{e.message}"
      end

      # Rate limiting - Open-Meteo allows 10,000 requests/day
      sleep 0.2
    end

    Rails.logger.info "Snow forecast refresh complete!"

    # New pages go to IndexNow right away; forecast pages are resubmitted once a day.
    IndexNowJob.perform_later if resort_ids.nil?
  end
end
