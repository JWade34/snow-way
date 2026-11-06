require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  PASSWORD = "test-admin-password-123"

  setup do
    @previous = ENV["ADMIN_PASSWORD"]
    ENV["ADMIN_PASSWORD"] = PASSWORD
    @auth = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("justin", PASSWORD) }
    @vail = resorts(:vail)
  end

  teardown { ENV["ADMIN_PASSWORD"] = @previous }

  test "admin is hidden without a password configured and locked without credentials" do
    ENV["ADMIN_PASSWORD"] = ""
    get "/admin"
    assert_response :not_found

    ENV["ADMIN_PASSWORD"] = PASSWORD
    get "/admin"
    assert_response :unauthorized
    get "/admin", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("justin", "wrong") }
    assert_response :unauthorized

    %w[/admin /admin/resorts /admin/import /admin/gear /admin/gear/new /admin/subscribers /admin/subscribers.csv].each do |path|
      get path, headers: @auth
      assert_response :success, path
      assert_equal "noindex, nofollow", response.headers["X-Robots-Tag"], path
    end
  end

  test "pasted notes mark resorts ridden and save draft takes and tips" do
    post "/admin/import", headers: @auth, params: { text: "Vail and Breck\nVail: back bowls on a powder day.\n- ride Blue Sky Basin early\nNowhere Peak: great" }
    assert_response :success
    visit = @vail.reload.visit
    assert_equal "back bowls on a powder day.", visit.take
    assert_equal [ "ride Blue Sky Basin early" ], visit.tips_list
    assert_not visit.published?
    assert_includes response.body, "Nowhere Peak"
    assert_nil LocalTake.for_resort("vail"), "drafts stay private"
  end

  test "published takes show on the resort page and the author page" do
    @vail.create_visit!(take: "Go to the back bowls.", tips: "Blue Sky early", published: true)
    get "/resorts/vail"
    assert_includes response.body, "Go to the back bowls."
    assert_includes response.body, "Local&#39;s take on Vail"
    get "/authors/justin-mckelvey"
    assert_includes response.body, "Resorts Justin has ridden"
  end

  test "unchecking a resort keeps a visit that has a take" do
    @vail.create_visit!(take: "Keep me")
    patch "/admin/resorts", headers: @auth, params: { resort_ids: [] }
    assert ResortVisit.exists?(resort: @vail)
  end

  test "what-i-ride lists only public gear and 404s when nothing is public" do
    GearItem.create!(category: "Snowboards", brand: "Burton", model: "Secret Board", notes: "paid $200")
    get "/what-i-ride"
    assert_response :not_found

    GearItem.create!(category: "Boots", brand: "Vans", model: "Infuse", public: true, public_note: "Comfy all day")
    get "/what-i-ride"
    assert_response :success
    assert_includes response.body, "Vans Infuse"
    assert_not_includes response.body, "Secret Board"
    assert_not_includes response.body, "paid $200"
    assert_includes SitePages.all_paths, "/what-i-ride"
  end
end
