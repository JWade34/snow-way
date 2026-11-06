require "test_helper"

class ResortsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get resorts_url
    assert_response :success
  end

  test "show targets the snow forecast query with answer, FAQ and schema" do
    get resort_url(resorts(:vail))
    assert_response :success
    assert_select "title", /Vail Snow Report & 14-Day Forecast/
    assert_select "h1", /Snow Report & Forecast/
    assert_select "section", /ranking #2 of 3/
    assert_select "a[href=?]", resort_path(resorts(:breckenridge))

    ld = css_select('script[type="application/ld+json"]').map { |s| JSON.parse(s.text) }
    graph = ld.find { |d| d["@graph"] }["@graph"]
    types = graph.map { |n| n["@type"] }
    assert_includes types, "SkiResort"
    assert_includes types, "FAQPage"
    assert_includes types, "BreadcrumbList"
    faq = graph.find { |n| n["@type"] == "FAQPage" }
    assert_equal "What is the snow report for Vail today?", faq["mainEntity"].first["name"]
  end
end
