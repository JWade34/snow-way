# Saves or removes a browser's powder alert notifications. Called from push_controller.js.
class PushSubscriptionsController < ApplicationController
  rate_limit to: 20, within: 1.hour, with: -> { head :too_many_requests }

  def create
    return head(:service_unavailable) unless PushSubscription.enabled?
    keys = params.dig(:subscription, :keys) || {}
    resort_id = Resort.where(id: params[:resort_id]).pick(:id) if params[:resort_id].present?
    sub = PushSubscription.find_or_initialize_by(endpoint: params.dig(:subscription, :endpoint).to_s, resort_id: resort_id)
    sub.assign_attributes(p256dh: keys[:p256dh].to_s, auth: keys[:auth].to_s,
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
    PushSubscription.where(endpoint: endpoint, resort_id: params[:resort_id].presence).destroy_all
    render json: { remaining: PushSubscription.where(endpoint: endpoint).count }
  end

  private

  def send_welcome(sub)
    where = sub.resort ? "#{sub.resort.name} gets #{sub.threshold_inches}\"+ in the forecast" : "a big storm lines up"
    PushDeliveryJob.perform_later(sub.id, title: "Powder alerts are on", body: "We'll let you know when #{where}.",
                                  url: "/?utm_source=push&utm_medium=notification&utm_campaign=welcome", tag: "welcome")
  end
end
