require "test_helper"

class IndexNowTest < ActiveSupport::TestCase
  test "submit_daily does nothing outside production" do
    assert_not IndexNow.submit_daily([ "https://snowway.app/" ])
  end

  test "forecast urls cover resort pages and hubs" do
    urls = SitePages.forecast_urls
    assert_includes urls, "https://snowway.app/resorts/vail"
    assert_includes urls, "https://snowway.app/where-is-it-snowing"
    assert urls.all? { |u| u.start_with?("https://snowway.app/") }
  end

  test "submit_new does nothing outside production" do
    assert_not IndexNow.submit_new([ "https://snowway.app/" ])
  end

  test "IndexNowJob runs without error outside production" do
    assert_nothing_raised { IndexNowJob.perform_now }
  end
end
