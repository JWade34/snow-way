# Receives navigator.sendBeacon pings for affiliate clicks. No cookies, no personal data: page, merchant, link label.
class TrackingController < ApplicationController
  skip_forgery_protection
  rate_limit to: 120, within: 1.minute, with: -> { head :too_many_requests }

  BOT = /bot|crawl|spider|slurp|headless|preview/i

  def affiliate
    page = params[:page].to_s
    href = params[:href].to_s
    if page.start_with?("/") && href.start_with?("http") && !request.user_agent.to_s.match?(BOT)
      AffiliateClick.create!(page_path: page.truncate(255, omission: ""), merchant: AffiliateClick.merchant_for(href), label: params[:label].to_s.squish.truncate(120).presence)
    end
    head :no_content
  end
end
