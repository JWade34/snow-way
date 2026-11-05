require "test_helper"

class SeoEndpointsTest < ActionDispatch::IntegrationTest
  test "llms.txt lists resorts with live totals" do
    get "/llms.txt"
    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_includes response.body, "[Vail snow forecast](https://snowway.app/resorts/vail): 6.5\""
  end

  test "llms-full.txt ranks resorts and includes answers" do
    get "/llms-full.txt"
    assert_response :success
    assert_match(/## 1\. Breckenridge/, response.body)
    assert_includes response.body, "Q: Will it snow at Vail this week?"
  end

  test "sitemap includes every resort" do
    get "/sitemap.xml"
    assert_response :success
    assert_includes response.body, "https://snowway.app/resorts/alyeska"
  end
end
