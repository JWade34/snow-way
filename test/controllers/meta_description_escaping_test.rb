require "test_helper"

class MetaDescriptionEscapingTest < ActionDispatch::IntegrationTest
  test "meta description is escaped once, so Google never shows &#39;" do
    get "/guides/balaclava-vs-ski-mask"
    assert_response :success
    desc = response.body[/<meta name="description" content="([^"]*)"/, 1]
    assert desc.present?
    assert_not_includes desc, "&amp;#39;"
    assert_not_includes desc, "&amp;amp;"
  end
end
