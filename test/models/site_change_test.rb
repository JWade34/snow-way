require "test_helper"

class SiteChangeTest < ActiveSupport::TestCase
  def stats(path, range, impressions:, clicks:, position: 8.0)
    SearchStat.store!(range.map { |d| { date: d, source: "google", page: path, query: "", clicks: clicks, impressions: impressions, position: position } })
  end

  test "guard skips pages without enough data and protects winners" do
    assert_equal :blocked, ChangeGuard.decide("/resorts/vail").verdict

    stats("/resorts/vail", (Date.current - 56)..(Date.current - 1), impressions: 40, clicks: 2, position: 2.0)
    assert_equal :approval, ChangeGuard.decide("/resorts/vail").verdict

    stats("/resorts/alyeska", (Date.current - 56)..(Date.current - 1), impressions: 20, clicks: 0, position: 9.0)
    assert ChangeGuard.decide("/resorts/alyeska").auto?
  end

  test "low-traffic title change goes live as an override, then reverts when it underperforms similar pages" do
    stats("/resorts/alyeska", (Date.current - 56)..(Date.current - 1), impressions: 20, clicks: 1, position: 9.0)
    change = SiteChange.propose!(path: "/resorts/alyeska", kind: "title", value: "Alyeska Snow Report: Alaska Powder Forecast | Snow Way", reason: "test")
    assert_equal "live", change.status
    assert_equal "Alyeska Snow Report: Alaska Powder Forecast | Snow Way", SeoOverride.for_path("/resorts/alyeska").title

    start = change.applied_at.to_date
    before = (start - 28)..(start - 1)
    after = start..(start + 27)
    stats("/resorts/alyeska", after, impressions: 20, clicks: 0)            # page lost clicks
    stats("/resorts/breckenridge", before, impressions: 30, clicks: 1)      # control stayed flat
    stats("/resorts/breckenridge", after, impressions: 30, clicks: 1)

    change.update!(evaluate_on: Date.current)
    travel_to(start + 35) { change.evaluate! }
    assert_equal "reverted", change.reload.status
    assert_nil SeoOverride.for_path("/resorts/alyeska")
  end

  test "a change that holds up against similar pages is kept" do
    stats("/resorts/alyeska", (Date.current - 56)..(Date.current - 1), impressions: 20, clicks: 1, position: 9.0)
    change = SiteChange.propose!(path: "/resorts/alyeska", kind: "description", value: "Alyeska snow report with the 7-day and 14-day forecast, new snow totals, and conditions for Girdwood, Alaska.", reason: "test")
    start = change.applied_at.to_date
    stats("/resorts/alyeska", start..(start + 27), impressions: 25, clicks: 2)
    travel_to(start + 35) { change.evaluate! }
    assert_equal "kept", change.reload.status
    assert SeoOverride.for_path("/resorts/alyeska").description.present?
  end
end
