require "test_helper"

class NewFeaturesTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  setup { Resort.sync_from_data_file! }

  test "season status: opened, upcoming, and passed-but-unconfirmed" do
    r = Resort.find_by(slug: "stowe")
    r.assign_attributes(opening_date: Date.new(2026, 11, 20), opening_status: "opened")
    assert_equal "Open", r.season_status(Date.new(2026, 11, 21))[:label]
    r.assign_attributes(opening_date: Date.new(2026, 11, 25), opening_status: "scheduled")
    assert_equal "Opens Nov 25", r.season_status(Date.new(2026, 11, 21))[:label]
    refute_equal "Open", r.season_status(Date.new(2026, 11, 30))[:label]
    r.opening_date = nil
    assert_nil r.season_status
  end

  test "sponsor shows only inside its dates" do
    Sponsor.instance_variable_set(:@placements, { "new-england" => { "name" => "Lodge", "headline" => "Stay", "url" => "https://example.com",
                                                                     "starts_on" => Date.new(2026, 12, 10), "ends_on" => Date.new(2027, 3, 31) } })
    assert_nil Sponsor.for("new-england", Date.new(2026, 12, 1))
    assert_equal "Lodge", Sponsor.for("new-england", Date.new(2027, 1, 5)).name
    assert_nil Sponsor.for("resort:stowe", Date.new(2027, 1, 5))
  ensure
    Sponsor.instance_variable_set(:@placements, nil)
  end

  test "weekend window rolls to next weekend from Saturday on" do
    assert_equal Date.new(2026, 11, 27), NewEnglandReport.new(Date.new(2026, 11, 21)).weekend[:checkin] # Saturday
    assert_equal Date.new(2026, 11, 27), NewEnglandReport.new(Date.new(2026, 11, 25)).weekend[:checkin] # Wednesday
    assert_equal Date.new(2026, 11, 27), NewEnglandReport.new(Date.new(2026, 11, 27)).weekend[:checkin] # Friday
  end

  test "New England subscribers get the New England email, not the national one" do
    ne = Subscriber.create!(email: "ne@example.com", page_path: "/new-england", weekly_report: true)
    other = Subscriber.create!(email: "west@example.com", page_path: "/resorts/alta", weekly_report: true)
    assert_enqueued_emails 1 do
      WeeklyReportJob.new.send(:send_new_england)
    end
    assert ne.reload.weekly_sent_at
    assert_nil other.reload.weekly_sent_at
  end
end
