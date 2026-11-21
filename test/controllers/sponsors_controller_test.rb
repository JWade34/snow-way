require "test_helper"

class SponsorsControllerTest < ActionDispatch::IntegrationTest
  test "inquiry emails Justin with reply-to the sender" do
    assert_enqueued_emails 1 do
      post "/sponsor", params: { inquiry: { name: "Pat", email: "pat@lodge.com", company: "Lodge", interest: "A resort page" } }
    end
    assert_response :success
    assert_select "p", /Thanks, got it/
  end

  test "honeypot and bad email send nothing" do
    assert_no_enqueued_emails do
      post "/sponsor", params: { inquiry: { name: "Bot", email: "bot@x.com", nickname: "x" } }
      post "/sponsor", params: { inquiry: { name: "Pat", email: "nope" } }
    end
  end
end
