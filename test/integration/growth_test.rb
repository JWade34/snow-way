require "test_helper"

class GrowthTest < ActionDispatch::IntegrationTest
  setup do
    @previous = ENV["ADMIN_PASSWORD"]
    ENV["ADMIN_PASSWORD"] = "test-admin-password-123"
    @auth = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("justin", "test-admin-password-123") }
  end

  teardown { ENV["ADMIN_PASSWORD"] = @previous }

  test "affiliate click beacon records page and merchant, ignores bots and junk" do
    post "/t/a", params: { page: "/guides/snowboard-boots", href: "https://www.rei.com/search?q=boots", label: "Shop boots" }
    assert_response :no_content
    click = AffiliateClick.last
    assert_equal [ "/guides/snowboard-boots", "rei", "Shop boots" ], [ click.page_path, click.merchant, click.label ]

    assert_no_difference -> { AffiliateClick.count } do
      post "/t/a", params: { page: "/x", href: "https://rei.com" }, headers: { "User-Agent" => "Googlebot/2.1" }
      post "/t/a", params: { page: "javascript:alert(1)", href: "https://rei.com" }
    end
  end

  test "signups remember the page they came from" do
    post "/subscribers", params: { subscriber: { email: "a@example.com" } }, headers: { "Referer" => "https://www.example.com/resorts/vail" }
    assert_equal "/resorts/vail", Subscriber.find_by(email: "a@example.com").page_path
  end

  test "growth tab and weekly email show the funnel by page" do
    day = GrowthReport.last_week.range.last
    SearchStat.store!([
      { date: day, source: "google", page: "/resorts/vail", query: "", clicks: 12, impressions: 400, position: 6.2 },
      { date: day, source: "google", page: "/resorts/vail", query: "vail snow forecast", clicks: 10, impressions: 300, position: 5.0 },
      { date: day, source: "google", page: "/guides/japan", query: "skiing in japan", clicks: 0, impressions: 50, position: 24.0 },
      { date: day, source: "bing", page: "/resorts/vail", query: "", clicks: 3, impressions: 40, position: 4.0 }
    ])
    AffiliateClick.create!(page_path: "/resorts/vail", merchant: "lodging", created_at: day.noon)

    get "/admin/growth?days=28", headers: @auth
    assert_response :success
    assert_includes response.body, "/resorts/vail"
    assert_includes response.body, "skiing in japan"

    report = GrowthReport.last_week
    vail = report.pages.find { |p| p.path == "/resorts/vail" }
    assert_equal [ 440, 15, 1 ], [ vail.impressions, vail.clicks, vail.affiliate_clicks ]
    assert_equal 6.2, vail.position

    mail = GrowthMailer.weekly(report)
    assert_includes mail.subject, "15 search clicks"
    assert_includes mail.body.encoded, "Search impressions: 440"
  end

  test "weekly email reminds about affiliate applications until their env var is set" do
    original = ENV.delete("AVANTLINK_WEBSITE_ID")
    assert_includes GrowthMailer.weekly.body.encoded, "AvantLink"
    ENV["AVANTLINK_WEBSITE_ID"] = "12345"
    assert_not_includes GrowthMailer.weekly.body.encoded, "AvantLink"
  ensure
    original ? ENV["AVANTLINK_WEBSITE_ID"] = original : ENV.delete("AVANTLINK_WEBSITE_ID")
  end

  test "an override replaces the page title and the changes page lists it" do
    SeoOverride.create!(path: "/resorts/vail", title: "Vail Snow Report Override Title | Snow Way")
    SiteChange.create!(path: "/resorts/vail", kind: "title", after_value: "Vail Snow Report Override Title | Snow Way", reason: "test", status: "proposed")
    get "/resorts/vail"
    assert_includes response.body, "<title>Vail Snow Report Override Title | Snow Way</title>"
    get "/admin/changes", headers: @auth
    assert_response :success
    assert_includes response.body, "Waiting for your OK"
  end

  test "loop feed needs the token or admin login" do
    ENV["LOOP_API_TOKEN"] = "loop-token-for-tests-123456"
    get "/admin/loop.json"
    assert_response :unauthorized
    get "/admin/loop.json", headers: { "Authorization" => "Bearer wrong" }
    assert_response :unauthorized
    get "/admin/loop.json", headers: { "Authorization" => "Bearer loop-token-for-tests-123456" }
    assert_response :success
    assert JSON.parse(response.body).key?("pages")
  ensure
    ENV.delete("LOOP_API_TOKEN")
  end

  test "social cards render as PNGs" do
    %w[report brand calendar].each do |kind|
      get "/social/#{kind}.png", params: { size: "story" }
      assert_response :success
      assert_equal "image/png", response.media_type
      assert_equal "\x89PNG".b, response.body.b[0, 4]
    end
  end

  test "thursday email drafts a reddit post from the powder report" do
    data = { "tracked" => 179, "snowing_count" => 40, "top" => [
      { "name" => "Stowe", "region" => "Vermont", "inches" => 12.4 }, { "name" => "Jay Peak", "region" => "Vermont", "inches" => 10.0 },
      { "name" => "Mt. Baker", "region" => "Washington", "inches" => 9.0 }, { "name" => "Sugarbush", "region" => "Vermont", "inches" => 8.0 },
      { "name" => "Alta", "region" => "Utah", "inches" => 7.0 } ] }
    body = GrowthMailer.thursday_post(data).body.encoded
    assert_includes body, "Stowe leads with 12\" forecast"
    assert_includes body, "1. Stowe (VT) 12\""
    assert_includes body, "Vermont has 3 of the top 10"
    assert_includes body, "snowway.app/social/report.png"
  end

  test "social planner fills the week and the admin queue lists it" do
    travel_to Time.find_zone("America/Denver").local(2026, 11, 8, 0, 30) do # a Sunday
      SocialPlanner.plan_week!
      assert_equal 7, SocialPost.where(kind: "report", format: "story").count
      assert_equal 1, SocialPost.where(kind: "report", format: "post").count
      tips = SocialPost.where(kind: "tip").order(:scheduled_for)
      assert_equal 3, tips.count
      assert_equal "family", tips.first.tip["category"]
      assert_equal 3, tips.map(&:tip_slug).uniq.size
      SocialPlanner.plan_week!
      assert_equal 11, SocialPost.count, "re-running doesn't duplicate"
      assert_includes tips.first.caption_text, "snowway.app/guides/"
      get "/admin/social", headers: @auth
      assert_response :success
      assert_includes response.body, "Meta isn't connected yet"
      get tips.first.image_url(host: "")
      assert_response :success
    end
  end

  test "publish job does nothing until Meta is connected" do
    SocialPost.create!(kind: "brand", format: "post", scheduled_for: 1.minute.ago)
    SocialPublishJob.perform_now
    assert_equal "queued", SocialPost.last.status
  end

  test "AI referrals are counted by source and shown in admin" do
    get "/resorts/vail", headers: { "HTTP_REFERER" => "https://chatgpt.com/" }
    get "/resorts/vail?utm_source=chatgpt.com"
    get "/resorts/vail", headers: { "HTTP_REFERER" => "https://www.perplexity.ai/search?q=x" }
    get "/resorts/vail", headers: { "HTTP_REFERER" => "https://www.google.com/" }
    assert_equal({ "chatgpt" => 2, "perplexity" => 1 }, AiReferral.totals_by_source)
    get "/admin/ai", headers: @auth
    assert_response :success
    assert_select "h1", "AI visibility"
  end

  test "AI citation check records whether snowway.app is cited" do
    AiCitations.record("perplexity", "vail snow forecast", Date.current) { { text: "Snow Way says 10 inches", sources: [ "https://snowway.app/resorts/vail", "https://www.opensnow.com/x" ] } }
    AiCitations.record("perplexity", "aspen vs vail", Date.current) { raise "HTTP 401" }
    checks = AiCitationCheck.latest_run.to_a
    assert_equal 50, AiCitationCheck.rate(checks.select(&:cited) + checks.reject(&:cited).reject(&:error) + [ AiCitationCheck.new(cited: false) ])
    assert checks.find(&:cited).mentioned
    assert_equal({ "opensnow.com" => 1 }, AiCitationCheck.competitors(checks))
    assert_nothing_raised { AiCitationJob.perform_now }
  end
end
