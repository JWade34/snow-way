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
end
