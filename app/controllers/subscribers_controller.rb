class SubscribersController < ApplicationController
  rate_limit to: 10, within: 1.hour, only: :create, with: -> { head :too_many_requests }
  skip_forgery_protection only: :unsubscribe # one-click unsubscribe POSTs from mail clients

  def create
    @subscriber = Subscriber.find_or_initialize_by(email: params.dig(:subscriber, :email).to_s.strip.downcase,
                                                   resort_id: params.dig(:subscriber, :resort_id).presence)
    @magnet = params.dig(:subscriber, :magnet).presence_in(LeadMagnetsController::MAGNETS.keys)
    @subscriber.assign_attributes(threshold_inches: params.dig(:subscriber, :threshold_inches).presence || 6,
                                  source: (@magnet || request.referer.to_s).truncate(255))
    newly_created = @subscriber.new_record?
    @saved = @subscriber.save
    if @saved && (newly_created || @magnet)
      @subscriber.update_columns(unsubscribed_at: nil, welcomed_at: Time.current)
      SubscriberMailer.welcome(@subscriber, @magnet).deliver_later
    end
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: @saved ? "You're on the powder alert list." : "Please enter a valid email." }
    end
  end

  def unsubscribe
    @subscriber = Subscriber.find_by(token: params[:token])
    @subscriber&.update_column(:unsubscribed_at, Time.current)
    request.post? ? head(:ok) : render(:unsubscribe)
  end
end
