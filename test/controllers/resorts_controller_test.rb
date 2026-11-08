require "test_helper"
require "minitest/mock"

class ResortsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get resorts_url
    assert_response :success
  end

  test "show targets the snow forecast query with answer, FAQ and schema" do
    get resort_url(resorts(:vail))
    assert_response :success
    assert_select "title", /Vail Snow Report, Weather & 14-Day Forecast/
    assert_select "h1", /Snow Report, Weather & Forecast/
    assert_select "section", /ranking #2 of 3/
    assert_select "a[href=?]", resort_path(resorts(:breckenridge))

    ld = css_select('script[type="application/ld+json"]').map { |s| JSON.parse(s.text) }
    graph = ld.flat_map { |d| d["@graph"] || [ d ] }
    types = graph.map { |n| n["@type"] }
    assert_includes types, "SkiResort"
    assert_includes types, "FAQPage"
    assert_includes types, "BreadcrumbList"
    faq = graph.find { |n| n["@type"] == "FAQPage" }
    assert_equal "What is the snow report for Vail today?", faq["mainEntity"].first["name"]
  end

  test "local's take box renders when Justin has notes for a resort" do
    LocalTake.stub(:for_resort, { take: "Test note.", tips: [ "Test tip." ] }.with_indifferent_access) do
      get resort_url(resorts(:vail))
    end
    assert_select "#local-take-heading", /Local's take on Vail/
    assert_select "section li", "Test tip."
  end

  test "where to stay page lists lodging areas with hotel searches and FAQ schema" do
    get where_to_stay_resort_url(resorts(:vail))
    assert_response :success
    assert_select "title", /Where to Stay in Vail/
    assert_select "h1", "Where to stay in Vail"
    assert_select "h3", "Lionshead Village"
    assert_select "a[href*='booking.com'][href*='Lionshead']"
    ld = css_select('script[type="application/ld+json"]').map { |s| JSON.parse(s.text) }
    graph = ld.flat_map { |d| d["@graph"] || [ d ] }
    faq = graph.find { |n| n["@type"] == "FAQPage" }
    assert_equal "Where should I stay in Vail?", faq["mainEntity"].first["name"]

    get resort_url(resorts(:vail))
    assert_select "a[href=?]", where_to_stay_resort_path(resorts(:vail))
  end

  test "where to stay 404s for resorts without lodging data" do
    get where_to_stay_resort_url(resorts(:alyeska))
    assert_response :not_found
  end

  test "ski boot size chart converts shoe sizes to mondopoint" do
    get ski_boot_size_chart_url
    assert_response :success
    assert_select "h1", /Ski boot size chart/
    assert_equal 27.0, SizeChart.mondo_from_us(9)
    assert_equal 25.0, SizeChart.mondo_from_us(8, womens: true)
  end

  test "state pages target best ski resorts in the state once there are three resorts" do
    get region_url("colorado")
    assert_select "h1", /Colorado ski resorts: snow report/

    Resort.create!(name: "Keystone", slug: "keystone", latitude: 39.6, longitude: -105.9, nearest_airport_code: "DEN",
                   state_province: "Colorado", country: "USA", elevation_base: 9280, elevation_summit: 12408, website_url: "https://www.keystoneresort.com")
    get region_url("colorado")
    assert_select "h1", /Best ski resorts in Colorado/
    assert_select "title", /Best Ski Resorts in Colorado/
  end

  test "comparison, snowiest and lift ticket pages render" do
    Resort.create!(name: "Aspen Snowmass", slug: "aspen-snowmass", latitude: 39.2, longitude: -106.9, nearest_airport_code: "ASE",
                   state_province: "Colorado", country: "USA", elevation_base: 8104, elevation_summit: 12510, website_url: "https://www.aspensnowmass.com")
    get comparison_url("aspen-vs-vail")
    assert_response :success
    assert_select "h1", /Aspen Snowmass vs Vail/
    get comparisons_url
    assert_select "a[href=?]", comparison_path("aspen-vs-vail")
    get snowiest_resorts_url
    assert_response :success
    get lift_tickets_resort_url(resorts(:vail))
    assert_response :success
    assert_select "h1", /Vail lift tickets/
    get lift_tickets_resort_url(resorts(:alyeska))
    assert_response :not_found
  end

  test "atom feed lists guides" do
    get "/feed.xml"
    assert_response :success
    assert_equal "application/atom+xml", response.media_type
    assert_includes response.body, "https://snowway.app/guides/how-to-ski"
  end

  test "getting there route pages render with drive times and FAQ" do
    get "/getting-there"
    assert_response :success
    pages = RoutePage.all
    assert pages.any?, "fixtures should cover at least one route"
    pages.each do |page|
      get "/getting-there/#{page.slug}"
      assert_response :success
      assert_includes response.body, "#{page.title} FAQ"
    end
    get "/getting-there/nowhere-to-nothing"
    assert_response :not_found
  end

  test "best places to ski by month pages render for each ski month" do
    SkiMonth.all.each do |month|
      get "/best-places-to-ski-in-#{month.slug}"
      assert_response :success
      assert_includes response.body, "Best places to ski in #{month.name}"
    end
    get "/best-places-to-ski-in-july"
    assert_response :not_found
  end
end
