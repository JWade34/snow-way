class IndexNowJob < ApplicationJob
  queue_as :default

  def perform
    IndexNow.submit_new(SitePages.all_paths.map { |path| SitePages.url(path) })
    IndexNow.submit_daily(SitePages.forecast_urls)
    # Guides edited in the last two weeks (dates come from git via db/guide_dates.yml).
    IndexNow.submit_changed(Guide.all.select { |g| g.updated_on >= 14.days.ago.to_date }
                                 .to_h { |g| [ SitePages.url("/guides/#{g.slug}"), g.updated_on ] })
  end
end
