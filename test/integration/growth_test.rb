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
end
