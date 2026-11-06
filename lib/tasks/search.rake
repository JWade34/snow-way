namespace :search do
  desc "Queue a 30-day Google/Bing backfill when a connected source has no data yet (runs on deploy)"
  task backfill_if_empty: :environment do
    missing = []
    missing << "google" if SearchConsole.configured? && !SearchStat.exists?(source: "google")
    missing << "bing" if BingWebmaster.configured? && !SearchStat.exists?(source: "bing")
    if missing.any?
      SearchStatsSyncJob.perform_later(days: 30)
      puts "queued 30-day search backfill (missing: #{missing.join(", ")})"
    end
  end
end
