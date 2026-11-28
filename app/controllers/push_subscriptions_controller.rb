# Saves or removes a browser's powder alert notifications. Called from push_controller.js.
class PushSubscriptionsController < ApplicationController
  rate_limit to: 20, within: 1.hour, with: -> { head :too_many_requests }
  # The iPhone app posts these from native code (no page, so no CSRF token). They only attach tokens to a known device.
  skip_forgery_protection only: [ :live_start, :live_activity ]

  def create
    platform = params[:platform].presence_in(PushSubscription::PLATFORMS) || "web"
    return head(:service_unavailable) unless platform == "ios" ? Apns.enabled? : PushSubscription.web_enabled?
    keys = params.dig(:subscription, :keys) || {}
    resort_id = Resort.where(id: params[:resort_id]).pick(:id) if params[:resort_id].present?
    crew_id = Crew.where(token: params[:crew_token]).pick(:id) if params[:crew_token].present?
    sub = PushSubscription.find_or_initialize_by(endpoint: params.dig(:subscription, :endpoint).to_s, resort_id: resort_id, crew_id: crew_id)
    sub.assign_attributes(platform: platform, p256dh: keys[:p256dh].to_s, auth: keys[:auth].to_s,
                          threshold_inches: (params[:threshold_inches].presence || 6).to_i.clamp(1, 48),
                          page_path: params[:page_path].to_s.truncate(255, omission: "").presence,
                          standalone: params[:standalone].to_s == "true", failures: 0)
    new_record = sub.new_record?
    if sub.save
      send_welcome(sub) if new_record
      head :created
    else
      head :unprocessable_entity
    end
  end

  # Turns off one alert (a resort's, or the general one). Says how many this device still has.
  def destroy
    endpoint = params[:endpoint].to_s
    crew_id = Crew.where(token: params[:crew_token]).pick(:id) if params[:crew_token].present?
    PushSubscription.where(endpoint: endpoint, resort_id: params[:resort_id].presence, crew_id: crew_id).destroy_all
    render json: { remaining: PushSubscription.where(endpoint: endpoint).count }
  end

  # Opts this device in or out of gear deal notifications or the Thursday Powder Report, for every alert it follows.
  # PATCH /push_subscriptions/settings { endpoint:, deals: true|false, weekly: true|false }
  def settings
    subs = PushSubscription.where(endpoint: params[:endpoint].to_s)
    return head(:not_found) if subs.none?
    changes = %w[deals weekly].select { |k| params.key?(k) }.to_h { |k| [ k, params[k].to_s == "true" ] }
    subs.update_all(changes.merge("updated_at" => Time.current)) if changes.any?
    render json: show_json(params[:endpoint].to_s)
  end

  # iPhone app: the token that lets us start a storm tracker on this device (iOS 17.2+).
  def live_start
    subs = PushSubscription.where(platform: "ios", endpoint: params[:endpoint].to_s)
    return head(:not_found) if subs.none?
    token = params[:start_token].to_s
    return head(:unprocessable_entity) unless token.match?(/\A\h{64,200}\z/)
    subs.update_all(live_start_token: token, updated_at: Time.current)
    head :no_content
  end

  # iPhone app: a running storm tracker's own update token.
  def live_activity
    resort = Resort.find_by(slug: params[:slug].to_s)
    token = params[:push_token].to_s
    return head(:unprocessable_entity) unless resort && token.match?(/\A\h{64,200}\z/) && PushSubscription.exists?(endpoint: params[:endpoint].to_s)
    la = LiveActivity.open.where(endpoint: params[:endpoint].to_s, resort: resort).order(:started_at).last ||
         LiveActivity.create!(endpoint: params[:endpoint].to_s, resort: resort, started_at: Time.current)
    la.update!(push_token: token)
    head :no_content
  end

  # GET /push_subscriptions?endpoint=... : what this device gets, for the app's Alerts settings page.
  def index
    render json: show_json(params[:endpoint].to_s)
  end

  private

  def show_json(endpoint)
    subs = PushSubscription.where(endpoint: endpoint).includes(:resort, :crew)
    { deals: subs.any?(&:deals), weekly: subs.any?(&:weekly),
      alerts: subs.map { |s| { resort_id: s.resort_id, crew_token: s.crew&.token, threshold_inches: s.threshold_inches,
                               label: s.crew ? "#{s.crew.name} crew" : (s.resort&.name || "Biggest storms anywhere") } } }
  end

  def send_welcome(sub)
    where = if sub.crew then "a resort your #{sub.crew.name} crew can ski gets #{Crew::ALERT_INCHES}\"+ in the forecast"
            elsif sub.resort then "#{sub.resort.name} gets #{sub.threshold_inches}\"+ in the forecast"
            else "a big storm lines up"
            end
    PushDeliveryJob.perform_later(sub.id, title: "Powder alerts are on", body: "We'll let you know when #{where}.",
                                  url: "/?utm_source=push&utm_medium=notification&utm_campaign=welcome", tag: "welcome")
  end
end
