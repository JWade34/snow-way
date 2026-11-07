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

namespace :resorts do
  desc "Write db/powder_odds.yml: % of days with 1\"+ fresh snow per ski-season month, 10 seasons of Open-Meteo history"
  task powder_odds: :environment do
    require "net/http"
    file = Rails.root.join("db/powder_odds.yml")
    out = File.exist?(file) ? (YAML.load_file(file) || {}) : {}
    out["resorts"] ||= {}
    Resort.north_america.order(:name).each do |r|
      next if out["resorts"][r.slug] && ENV["FORCE"].blank?
      mid = ((r.elevation_base.to_i + r.elevation_summit.to_i) / 2.0 * 0.3048).round
      uri = URI("https://archive-api.open-meteo.com/v1/archive?" + {
        latitude: r.latitude.to_f, longitude: r.longitude.to_f, elevation: mid,
        start_date: "2015-07-01", end_date: "2025-06-30", daily: "snowfall_sum", timezone: "auto"
      }.to_query)
      body = nil
      3.times do |attempt|
        res = Net::HTTP.get_response(uri)
        if res.code == "200" then body = JSON.parse(res.body); break end
        puts "#{r.slug}: HTTP #{res.code}, retrying"; sleep 20 * (attempt + 1)
      end
      next puts("#{r.slug}: skipped") unless body
      days = body.dig("daily", "time").zip(body.dig("daily", "snowfall_sum"))
      by_month = days.group_by { |d, _| d[5, 2].to_i }
      odds = r.ski_season_months.to_h do |m|
        rows = by_month.fetch(m, []).reject { |_, v| v.nil? }
        [ m, rows.empty? ? 0 : (rows.count { |_, v| v >= 2.54 } * 100.0 / rows.size).round ]
      end
      out["resorts"][r.slug] = odds
      out["source"] = "Open-Meteo historical weather (ERA5-based), July 2015 to June 2025, mid-mountain elevation; a fresh-snow day is 1 inch or more of modeled snowfall"
      out["generated_on"] = Date.current.iso8601
      File.write(file, out.to_yaml)
      puts "#{r.slug}: #{odds.inspect}"
      sleep 1.5
    end
  end
end
