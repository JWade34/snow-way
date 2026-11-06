class IndexNowJob < ApplicationJob
  queue_as :default

  def perform
    IndexNow.submit_new(SitePages.all_paths.map { |path| SitePages.url(path) })
    IndexNow.submit_daily(SitePages.forecast_urls)
  end
end
