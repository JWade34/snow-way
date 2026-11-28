require "test_helper"
require "minitest/mock"

# Crews, pass filter, notification settings, storm tracker, Thursday push, tip jar and the Black Friday page.
class AppGrowthFeaturesTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    resorts(:vail).update!(pass: "epic", other_passes: [])
    resorts(:breckenridge).update!(pass: "epic", other_passes: [ "indy" ])
    resorts(:alyeska).update!(pass: "ikon", other_passes: [])
  end

  test "pass filter keeps resorts on that pass" do
    assert resorts(:vail).on_pass?("epic")
    assert_not resorts(:vail).on_pass?("ikon")
    assert resorts(:breckenridge).on_pass?("indy")
    get "/api/app/powder?pass=ikon"
    assert_equal [ resorts(:alyeska).slug ], response.parsed_body["resorts"].map { |r| r["slug"] }
    get "/api/app/powder?lat=#{resorts(:vail).latitude}&lng=#{resorts(:vail).longitude}&miles=100"
    assert_not_includes response.parsed_body["resorts"].map { |r| r["slug"] }, resorts(:alyeska).slug
  end

  test "a crew is made, joined, and ranks resorts on everyone's passes" do
    post "/crew", params: { name: "Shredders", member_name: "Jo", pass: "epic" }
    crew = Crew.last
    assert_redirected_to "/crew/#{crew.token}?created=1"
    follow_redirect!
    assert_select "h1", "Shredders"
    assert_select "a[href^='sms:']"
    assert_select "form[action='/crew/#{crew.token}/join']", count: 0 # the creator is already in
    assert_select "meta[name=robots][content*=noindex]"

    other = open_session
    other.get "/crew/#{crew.token}"
    other.assert_select "form[action='/crew/#{crew.token}/join']"
    other.post "/crew/#{crew.token}/join", params: { member_name: "Sam", pass: "indy" }
    assert_equal 2, crew.members.count
    ids = crew.shared_resorts.map(&:id)
    assert_includes ids, resorts(:breckenridge).id # Epic and Indy
    assert_not_includes ids, resorts(:vail).id     # Epic only
  end

  test "settings page and API show this device's alerts, weekly and deals" do
    get "/notifications"
    assert_response :success
    sub = PushSubscription.create!(platform: "ios", endpoint: "c" * 64, p256dh: "", auth: "", resort: resorts(:vail))
    get "/push_subscriptions", params: { endpoint: sub.endpoint }
    assert_equal "Vail", response.parsed_body["alerts"].first["label"]
    patch "/push_subscriptions/settings", params: { endpoint: sub.endpoint, weekly: true }, as: :json
    assert response.parsed_body["weekly"]
    assert sub.reload.weekly
    assert_not sub.deals
  end

  test "storm tracker starts once for a big storm and ends when it passes" do
    sub = PushSubscription.create!(platform: "ios", endpoint: "d" * 64, p256dh: "", auth: "", resort: resorts(:vail))
    post "/push_subscriptions/live_start", params: { endpoint: sub.endpoint, start_token: "e" * 64 }, as: :json
    assert_response :no_content
    calls = []
    fake = ->(**kw) { calls << kw; Apns::Result.new(ok: true, gone: false) }
    Apns.stub(:enabled?, true) do
      Apns.stub(:live_activity, fake) do
        StormTracker.run({ resorts(:vail).id => 14.0 }, { resorts(:vail).id => 20.0 })
        StormTracker.run({ resorts(:vail).id => 14.0 }, { resorts(:vail).id => 20.0 }) # no second start
        assert_equal [ "start" ], calls.map { |c| c[:event] }
        post "/push_subscriptions/live_activity", params: { endpoint: sub.endpoint, slug: "vail", push_token: "f" * 64 }, as: :json
        assert_response :no_content
        StormTracker.run({ resorts(:vail).id => 0.5 }, { resorts(:vail).id => 1.0 })
      end
    end
    assert_equal %w[start end], calls.map { |c| c[:event] }
    assert_equal 14, calls.first[:state][:next3DaysIn]
    assert LiveActivity.last.ended_at
  end

  test "Thursday Powder Report goes to devices that opted in" do
    PushSubscription.create!(platform: "ios", endpoint: "a1" * 32, p256dh: "", auth: "", weekly: true)
    PushSubscription.create!(platform: "ios", endpoint: "b2" * 32, p256dh: "", auth: "")
    Apns.stub(:enabled?, true) do
      Resort.stub(:projected_totals, { resorts(:vail).id => 10.0 }) do
        assert_enqueued_jobs(1, only: PushDeliveryJob) { WeeklyReportJob.perform_now }
      end
    end
  end

  test "tip jar uses the original Stripe link until new links are set" do
    get "/about"
    assert_select "[data-tip-jar] a[data-tip=hot_chocolate][href='#{TipJar::ORIGINAL_LINK}']"
    assert_select "[data-tip-jar] a[data-tip=apres]", count: 0
    ENV["TIP_APRES_URL"] = "https://buy.stripe.com/test_x"
    ENV["TIP_APRES_PRICE"] = "$20"
    get "/about"
    assert_select "[data-tip-jar] a[data-tip=apres][href='https://buy.stripe.com/test_x']", text: /\$20/
  ensure
    ENV.delete("TIP_APRES_URL")
    ENV.delete("TIP_APRES_PRICE")
  end

  test "Black Friday page lists live deals and drops expired ones" do
    travel_to Date.new(2026, 11, 27) do
      get "/black-friday-ski-deals"
      assert_response :success
      assert_select "a[data-deal=evo]"
    end
    travel_to Date.new(2026, 11, 29) do
      get "/black-friday-ski-deals"
      assert_select "a[data-deal=evo]", count: 0
      assert_select "a[data-deal=christy-sports]"
    end
    travel_to Date.new(2026, 12, 10) do
      get "/black-friday-ski-deals"
      assert_select "a[data-deal]", count: 0
    end
  end
end
