# Sends powder alerts to the Snow Way iPhone app through Apple Push Notification service (token auth).
# Off until these Railway variables exist: APNS_KEY_P8 (the .p8 key's text), APNS_KEY_ID.
# APNS_ENV=development for Xcode builds; App Store and TestFlight builds use production (the default).
module Apns
  TEAM_ID = "K36P898K34" # Fast City LLC
  TOPIC = "app.snowway"  # bundle ID

  Result = Data.define(:ok, :gone)

  module_function

  def enabled? = ENV["APNS_KEY_P8"].present? && ENV["APNS_KEY_ID"].present?

  def deliver(token:, title:, body:, url:, tag:)
    notification = Apnotic::Notification.new(token)
    notification.topic = TOPIC
    notification.alert = { title: title, body: body }
    notification.sound = "default"
    notification.thread_id = tag
    notification.custom_payload = { url: url }
    notification.expiration = 12.hours.from_now.to_i
    response = connection.push(notification, timeout: 10)
    return Result.new(ok: false, gone: false) unless response
    gone = response.status == "410" || (response.status == "400" && response.body["reason"].in?(%w[BadDeviceToken DeviceTokenNotForTopic]))
    Result.new(ok: response.ok?, gone: gone)
  end

  def connection
    @connection ||= begin
      options = { auth_method: :token, cert_path: StringIO.new(ENV.fetch("APNS_KEY_P8").gsub("\\n", "\n")), key_id: ENV.fetch("APNS_KEY_ID"), team_id: TEAM_ID }
      ENV["APNS_ENV"] == "development" ? Apnotic::Connection.development(options) : Apnotic::Connection.new(options)
    end
  end
end
