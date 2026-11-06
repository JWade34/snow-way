require "test_helper"

class PowderAlertJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  test "alerts resort subscribers over threshold once, then respects the cooldown" do
    over = Subscriber.create!(email: "over@example.com", resort: resorts(:vail), threshold_inches: 6)
    under = Subscriber.create!(email: "under@example.com", resort: resorts(:vail), threshold_inches: 18)
    assert_enqueued_emails 1 do
      PowderAlertJob.perform_now
    end
    assert over.reload.last_alerted_at
    assert_nil under.reload.last_alerted_at
    assert_no_enqueued_emails { PowderAlertJob.perform_now }
  end

  test "unsubscribed people get nothing" do
    Subscriber.create!(email: "gone@example.com", resort: resorts(:vail), threshold_inches: 6, unsubscribed_at: Time.current)
    assert_no_enqueued_emails { PowderAlertJob.perform_now }
  end
end
