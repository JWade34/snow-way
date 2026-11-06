namespace :search do
  desc "Queue a 30-day Google/Bing backfill when search_stats is empty (runs on deploy)"
  task backfill_if_empty: :environment do
    if SearchStat.exists?
      puts "search_stats already has data"
    elsif SearchConsole.configured? || BingWebmaster.configured?
      SearchStatsSyncJob.perform_later(days: 30)
      puts "queued 30-day search backfill"
    end
  end
end
