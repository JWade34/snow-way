namespace :resorts do
  desc "Upsert resorts from db/resorts.yml and queue forecasts for any new ones"
  task sync: :environment do
    created = Resort.sync_from_data_file!
    puts "Resorts synced: #{Resort.count} total, #{created.size} new#{created.any? ? " (#{created.map(&:name).join(", ")})" : ""}"
    RefreshSnowForecastsJob.perform_later(created.map(&:id)) if created.any?
  end
end
