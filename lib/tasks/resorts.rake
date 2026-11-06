namespace :resorts do
  desc "Upsert resorts from db/resorts.yml and queue forecasts for any new ones"
  task sync: :environment do
    created = Resort.sync_from_data_file!
    puts "Resorts synced: #{Resort.count} total, #{created.size} new#{created.any? ? " (#{created.map(&:name).join(", ")})" : ""}"
    if SnowForecast.where(forecast_date: Date.current.., snowfall_summit_inches: nil).exists?
      RefreshSnowForecastsJob.perform_later # forecasts predate mid-mountain/summit split; refresh everything now
    elsif created.any?
      RefreshSnowForecastsJob.perform_later(created.map(&:id))
    end
    IndexNowJob.perform_later # runs on every deploy: submits any never-submitted URLs
  end
end
