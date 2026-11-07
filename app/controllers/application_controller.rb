class ApplicationController < ActionController::Base
  before_action :redirect_www
  after_action :track_ai_referral


  private

  def track_ai_referral
    return unless request.get? && response.successful? && request.format.html?
    source = AiReferral.source_for(request.referer, params[:utm_source]) or return
    AiReferral.track(source: source, path: request.path)
  rescue StandardError => e
    Rails.logger.warn("AI referral tracking failed: #{e.message}")
  end

  def redirect_www
    if request.host == "www.snowway.app"
      redirect_to "https://snowway.app#{request.fullpath}", status: :moved_permanently, allow_other_host: true
    end
  end
end
