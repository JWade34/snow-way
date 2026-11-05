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
end
