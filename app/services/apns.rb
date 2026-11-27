# Sends powder alerts to the Snow Way iPhone app through Apple Push Notification service (token auth).
# Off until these Railway variables exist: APNS_KEY_P8 (the .p8 key's text), APNS_KEY_ID.
# APNS_ENV=development for Xcode builds; App Store and TestFlight builds use production (the default).
module Apns
  TEAM_ID = "K36P898K34" # Fast City LLC
  TOPIC = "app.snowway"  # bundle ID

  Result = Data.define(:ok, :gone)

  module_function

  def enabled? = ENV["APNS_KEY_P8"].present? && ENV["APNS_KEY_ID"].present?

  # Native extras (all optional):
  #   subtitle  second line under the title
  #   category  POWDER_ALERT or GEAR_DEAL: the buttons on a long-pressed notification (set up in the app's AppDelegate)
  #   level     "time-sensitive" breaks through Focus (big storms only), "passive" arrives quietly (deals), else "active"
  #   relevance 0..1, how high it sorts in the notification summary
  #   image     https URL the app's notification extension attaches as a picture
  #   stay_url  page the "Places to stay" button opens
  def deliver(token:, title:, body:, url:, tag:, subtitle: nil, category: nil, level: nil, relevance: nil, image: nil, stay_url: nil)
    notification = Apnotic::Notification.new(token)
    notification.topic = TOPIC
    notification.alert = { title: title, subtitle: subtitle, body: body }.compact
    notification.sound = level == "passive" ? nil : "default"
    notification.badge = 1
    notification.thread_id = tag
    notification.category = category
    notification.interruption_level = level if level.in?(%w[passive active time-sensitive])
    notification.relevance_score = relevance.to_f.clamp(0, 1) if relevance
    notification.mutable_content = 1 if image
    notification.custom_payload = { url: url, image: image, stay_url: stay_url }.compact
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
