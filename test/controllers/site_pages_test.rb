require "test_helper"

class SitePagesTest < ActionDispatch::IntegrationTest
  test "every indexable page renders with one h1, a title, and valid JSON-LD" do
    SitePages.all_paths.each do |path|
      get path
      assert_response :success, "#{path} failed"
      assert_select "h1", { count: 1 }, "#{path} needs exactly one h1"
      assert_select "title"
      css_select('script[type="application/ld+json"]').each { |s| JSON.parse(s.text) }
    end
  end

  test "sitemap lists every indexable page" do
    get "/sitemap.xml"
    SitePages.all_paths.each { |path| assert_includes response.body, "<loc>#{SitePages.url(path)}</loc>" }
  end

  test "IndexNow key file is served" do
    get "/#{IndexNow::KEY}.txt"
    assert_response :success
    assert_equal IndexNow::KEY, response.body
  end

  test "embed allows framing and is noindex" do
    get "/embed/powder-rankings"
    assert_response :success
    assert_nil response.headers["X-Frame-Options"]
    assert_select "meta[name=robots][content=noindex]"
  end

  test "resort share image is a PNG" do
    get "/og/resorts/vail.png"
    assert_response :success
    assert_equal "image/png", response.media_type
    assert response.body.start_with?("\x89PNG".b)
  end

  test "city hub pages list nearby resorts by distance" do
    Resort.sync_from_data_file!
    get "/ski-resorts-near/denver"
    assert_response :success
    assert_select "h1", "Ski resorts near Denver"
    assert_select "table tbody tr", minimum: 3
  end

  test "region page answers which resort has the most snow" do
    get "/ski-resorts/colorado"
    assert_select "section", /Breckenridge leads Colorado with 9.0"/
  end

  test "unknown region, hub, and guide return 404" do
    %w[/ski-resorts/narnia /ski-resorts-near/atlantis /guides/nope].each do |path|
      get path
      assert_response :not_found, path
    end
  end

  test "powder alert signup stores a subscriber once per email and resort" do
    assert_difference "Subscriber.count", 1 do
      post subscribers_path, params: { subscriber: { email: " Skier@Example.com ", resort_id: resorts(:vail).id, threshold_inches: 12 } }, as: :turbo_stream
    end
    assert_response :success
    assert_equal "skier@example.com", Subscriber.last.email
    assert_no_difference "Subscriber.count" do
      post subscribers_path, params: { subscriber: { email: "skier@example.com", resort_id: resorts(:vail).id } }, as: :turbo_stream
    end
  end

  test "invalid email is rejected" do
    assert_no_difference "Subscriber.count" do
      post subscribers_path, params: { subscriber: { email: "not-an-email" } }, as: :turbo_stream
    end
  end

  test "powder report snapshots are archived and listed" do
    report = PowderReport.snapshot!
    get "/powder-report/#{report.week_of.iso8601}"
    assert_response :success
    assert_select "h1", /Breckenridge leads North America/
    get "/powder-report"
    assert_select "a[href=?]", "/powder-report/#{report.week_of.iso8601}"
  end

  test "powder calendar signup returns a working PDF download" do
    post subscribers_path, params: { subscriber: { email: "cal@example.com", magnet: "powder-calendar" } }, as: :turbo_stream
    subscriber = Subscriber.find_by!(email: "cal@example.com")
    assert_equal "powder-calendar", subscriber.source
    assert_includes response.body, powder_calendar_download_path(subscriber.token)
    get powder_calendar_download_path(subscriber.token)
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF")
  end

  test "calendar download requires a valid token" do
    get powder_calendar_download_path("nope")
    assert_response :not_found
  end

  test "packing checklist signup returns a PDF" do
    post subscribers_path, params: { subscriber: { email: "pack@example.com", magnet: "packing-checklist" } }, as: :turbo_stream
    subscriber = Subscriber.find_by!(email: "pack@example.com")
    assert_includes response.body, lead_magnet_download_path("packing-checklist", subscriber.token)
    get lead_magnet_download_path("packing-checklist", subscriber.token)
    assert_equal "application/pdf", response.media_type
    get lead_magnet_download_path("nope", subscriber.token)
    assert_response :not_found
  end
end
