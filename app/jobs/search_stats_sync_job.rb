# Daily: pull the last 10 days from Google (data settles over ~3 days, so recent days get refreshed)
# and the latest Bing stats into search_stats. The outcome per source shows on the admin Growth tab.
class SearchStatsSyncJob < ApplicationJob
  queue_as :default

  STATUS_KEY = "search_stats_sync_status".freeze

  def self.status
    Rails.cache.read(STATUS_KEY) || {}
  end

  def perform(days: 10)
    status = self.class.status.dup
    status["google"] = sync("google") { SearchConsole.new.daily_rows((Date.current - days)..(Date.current - 1)) } if SearchConsole.configured?
    status["bing"] = sync("bing") { BingWebmaster.new.daily_rows } if BingWebmaster.configured?
    Rails.cache.write(STATUS_KEY, status)
  end

  private

  def sync(source)
    rows = SearchStat.store!(yield)
    { "at" => Time.current, "ok" => true, "message" => "#{rows} rows" }
  rescue StandardError => e
    Rails.logger.error "[SearchStatsSync] #{source} failed: #{e.class}: #{e.message}"
    { "at" => Time.current, "ok" => false, "message" => "#{e.class}: #{e.message.truncate(200)}" }
  end
end
