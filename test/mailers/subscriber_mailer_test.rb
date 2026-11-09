require "test_helper"

class SubscriberMailerTest < ActionMailer::TestCase
  setup do
    @subscriber = Subscriber.create!(email: "mail@example.com", resort: resorts(:vail), threshold_inches: 6)
  end

  test "welcome email includes the download link and one-click unsubscribe headers" do
    mail = SubscriberMailer.welcome(@subscriber, "powder-calendar")
    assert_equal [ "mail@example.com" ], mail.to
    assert_match "Powder Calendar", mail.subject
    assert_match "/powder-calendar/download/#{@subscriber.token}", mail.html_part.body.to_s
    assert_match "/unsubscribe/#{@subscriber.token}", mail.header["List-Unsubscribe"].to_s
    assert_equal "List-Unsubscribe=One-Click", mail.header["List-Unsubscribe-Post"].to_s
  end

  test "powder alert names the resort and amount" do
    mail = SubscriberMailer.powder_alert(@subscriber, [ [ resorts(:vail), 14.2 ], [ resorts(:breckenridge), 9.0 ] ])
    assert_match "Vail forecast 14\"", mail.subject
    assert_match "Breckenridge", mail.html_part.body.to_s
  end

  test "weekly report lists the leaders, the subscriber's mountain and both opt-out links" do
    @subscriber.update!(weekly_report: true)
    mail = SubscriberMailer.weekly_report(@subscriber, [ [ resorts(:vail), 14.2 ], [ resorts(:breckenridge), 9.0 ] ], [ [ resorts(:vail), 14.2 ] ])
    assert_match "Vail leads with 14\"", mail.subject
    body = mail.html_part.body.to_s
    assert_match "Breckenridge", body
    assert_match "Your mountain", body
    assert_match "/weekly/#{@subscriber.token}", body
    assert_match "/unsubscribe/#{@subscriber.token}", mail.header["List-Unsubscribe"].to_s
  end
end
