require "test_helper"

class LlmsGuidesTest < ActionDispatch::IntegrationTest
  test "llms-full includes every guide with its FAQ" do
    get "/llms-full.txt"
    assert_response :success
    assert_equal Guide.all.size, response.body.scan(%r{^URL: https://snowway.app/guides/}).size
    assert_match(/^Q: /, response.body.split("# Snow Way guides").last)
  end
end
