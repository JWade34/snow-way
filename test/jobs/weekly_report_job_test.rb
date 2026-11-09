require "test_helper"

class WeeklyReportJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends once per email to opted-in subscribers only, then waits a week" do
    Subscriber.create!(email: "weekly@example.com", resort: resorts(:vail), weekly_report: true)
    Subscriber.create!(email: "weekly@example.com", resort: resorts(:breckenridge), weekly_report: true)
    Subscriber.create!(email: "alerts-only@example.com", resort: resorts(:vail))
    Subscriber.create!(email: "gone@example.com", weekly_report: true, unsubscribed_at: Time.current)
    assert_enqueued_emails 1 do
      WeeklyReportJob.perform_now
    end
    assert_no_enqueued_emails { WeeklyReportJob.perform_now }
  end
end
