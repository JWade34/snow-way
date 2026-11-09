class SubscribersController < ApplicationController
  rate_limit to: 10, within: 1.hour, only: :create, with: -> { head :too_many_requests }
  skip_forgery_protection only: [ :unsubscribe, :weekly ] # one-click unsubscribe POSTs from mail clients

  def create
    @subscriber = Subscriber.find_or_initialize_by(email: params.dig(:subscriber, :email).to_s.strip.downcase,
                                                   resort_id: params.dig(:subscriber, :resort_id).presence)
    @magnet = params.dig(:subscriber, :magnet).presence_in(LeadMagnetsController::MAGNETS.keys)
    @subscriber.assign_attributes(threshold_inches: params.dig(:subscriber, :threshold_inches).presence || 6,
                                  source: (@magnet || request.referer.to_s).truncate(255),
                                  page_path: referer_path, weekly_report: true) # the form's consent text names the weekly report
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

  # Opt in or out of the Thursday weekly report only. GET shows a button (so link scanners can't change it); POST applies.
  def weekly
    @subscriber = Subscriber.find_by(token: params[:token])
    if request.post? && @subscriber
      @subscriber.update_columns(weekly_report: params[:on] == "1", unsubscribed_at: (params[:on] == "1" ? nil : @subscriber.unsubscribed_at))
      @changed = true
    end
    render :weekly
  end

  private

  def referer_path
    uri = URI.parse(request.referer.to_s)
    uri.path.presence&.truncate(255, omission: "") if uri.host.nil? || uri.host.end_with?("snowway.app") || uri.host == request.host
  rescue URI::InvalidURIError
    nil
  end
end
