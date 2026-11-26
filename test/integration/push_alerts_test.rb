require "test_helper"
require "minitest/mock"

class PushAlertsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @saved = ENV.to_h.slice("VAPID_PUBLIC_KEY", "VAPID_PRIVATE_KEY")
    key = WebPush.generate_key
    ENV["VAPID_PUBLIC_KEY"], ENV["VAPID_PRIVATE_KEY"] = key.public_key, key.private_key
  end

  teardown do
    %w[VAPID_PUBLIC_KEY VAPID_PRIVATE_KEY].each { |k| @saved.key?(k) ? ENV[k] = @saved[k] : ENV.delete(k) }
  end

  def subscription_params(endpoint = "https://fcm.googleapis.com/fcm/send/abc123")
    { subscription: { endpoint: endpoint, keys: { p256dh: "BNcRdreALRFXTkOOUHK1EtK2wtaz5Ry4YfYCA_0QTpQtUbVlUls0VJXg7A8u-Ts1XbjhazAkj7I99e8QcYP7DkM", auth: "tBHItJI5svbpez7KI4CCXg" } } }
  end

  test "pages show the notification option only when push keys are set" do
    get "/app"
    assert_select "meta[name=vapid-public-key]"
    assert_select "[data-controller=push] [data-action='push#enable']"
    ENV.delete("VAPID_PUBLIC_KEY")
    get "/app"
    assert_select "meta[name=vapid-public-key]", count: 0
    assert_select "[data-controller=push]", count: 0
  end

  test "resort alert forms offer notifications for that resort" do
    get "/resorts/#{resorts(:vail).slug}"
    assert_select "#alert-form [data-controller=push][data-push-resort-id-value='#{resorts(:vail).id}']"
  end

  test "saving a subscription stores it per resort and sends a welcome notification" do
    assert_enqueued_with(job: PushDeliveryJob) do
      post "/push_subscriptions", params: subscription_params.merge(resort_id: resorts(:vail).id, threshold_inches: 12, page_path: "/resorts/vail"), as: :json
    end
    assert_response :created
    post "/push_subscriptions", params: subscription_params, as: :json # same phone, general alerts too
    assert_equal 2, PushSubscription.count
    sub = PushSubscription.find_by(resort: resorts(:vail))
    assert_equal 12, sub.threshold_inches

    delete "/push_subscriptions", params: { endpoint: sub.endpoint, resort_id: resorts(:vail).id }, as: :json
    assert_equal 1, response.parsed_body["remaining"]
    assert_equal 1, PushSubscription.count
  end

  test "rejects bad subscriptions and refuses when push is off" do
    post "/push_subscriptions", params: subscription_params("http://insecure.example/x"), as: :json
    assert_response :unprocessable_entity
    ENV.delete("VAPID_PRIVATE_KEY")
    post "/push_subscriptions", params: subscription_params, as: :json
    assert_response :service_unavailable
    assert_equal 0, PushSubscription.count
  end

  test "powder alert job notifies devices over their threshold once per cooldown" do
    over = PushSubscription.create!(subscription_params[:subscription].slice(:endpoint).merge(p256dh: "k", auth: "a", resort: resorts(:vail), threshold_inches: 6))
    under = PushSubscription.create!(endpoint: "https://fcm.googleapis.com/fcm/send/other", p256dh: "k", auth: "a", resort: resorts(:vail), threshold_inches: 48)
    totals = { resorts(:vail).id => 20.0 }
    Resort.stub(:projected_totals, totals) do
      assert_enqueued_jobs(1, only: PushDeliveryJob) { PowderAlertJob.perform_now }
      assert over.reload.last_alerted_at
      assert_nil under.reload.last_alerted_at
      assert_no_enqueued_jobs(only: PushDeliveryJob) { PowderAlertJob.perform_now }
    end
    msg = PowderAlertJob.push_message([ [ resorts(:vail), 20.4 ] ])
    assert_equal "#{resorts(:vail).name}: 20\" in the next 3 days", msg[:title]
    assert_includes msg[:url], "/resorts/#{resorts(:vail).slug}?utm_source=push"
  end

  test "a subscription the push service says is gone is deleted for every resort" do
    a = PushSubscription.create!(endpoint: "https://web.push.apple.com/x", p256dh: "k", auth: "a", resort: resorts(:vail))
    PushSubscription.create!(endpoint: "https://web.push.apple.com/x", p256dh: "k", auth: "a")
    gone = ->(**) { raise WebPush::ExpiredSubscription.new(Struct.new(:body).new(""), "web.push.apple.com") }
    WebPush.stub(:payload_send, gone) { assert_not a.deliver(title: "t", body: "b", url: "/") }
    assert_equal 0, PushSubscription.count
  end

  test "service worker shows notifications and opens their page" do
    get "/service-worker.js"
    assert_includes response.body, "showNotification"
    assert_includes response.body, "notificationclick"
  end
end
