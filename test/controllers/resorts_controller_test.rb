require "test_helper"

class ResortsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get resorts_url
    assert_response :success
  end

  test "should get show" do
    resort = Resort.first || Resort.create!(name: "Test Resort", latitude: 40.0, longitude: -105.0, state: "CO")
    get resort_url(resort)
    assert_response :success
  end
end
