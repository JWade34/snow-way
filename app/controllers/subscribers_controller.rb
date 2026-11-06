class SubscribersController < ApplicationController
  rate_limit to: 10, within: 1.hour, only: :create, with: -> { head :too_many_requests }

  def create
    @subscriber = Subscriber.find_or_initialize_by(email: params.dig(:subscriber, :email).to_s.strip.downcase,
                                                   resort_id: params.dig(:subscriber, :resort_id).presence)
    @subscriber.assign_attributes(threshold_inches: params.dig(:subscriber, :threshold_inches).presence || 6,
                                  source: request.referer.to_s.truncate(255))
    @saved = @subscriber.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: @saved ? "You're on the powder alert list." : "Please enter a valid email." }
    end
  end
end
