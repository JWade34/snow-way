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
end
