# Daily: pull the last 10 days from Google (data settles over ~3 days, so recent days get refreshed)
# and the latest Bing stats into search_stats.
class SearchStatsSyncJob < ApplicationJob
  queue_as :default

  def perform(days: 10)
    if SearchConsole.configured?
      range = (Date.current - days)..(Date.current - 1)
      Rails.logger.info "[SearchStatsSync] google rows: #{SearchStat.store!(SearchConsole.new.daily_rows(range))}"
    end
    if BingWebmaster.configured?
      Rails.logger.info "[SearchStatsSync] bing rows: #{SearchStat.store!(BingWebmaster.new.daily_rows)}"
    end
  end
end
