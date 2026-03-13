class ApplicationController < ActionController::Base
  before_action :redirect_www

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Skip for crawlers/bots (iMessage, Facebook, Twitter, etc.) so link previews work
  allow_browser versions: :modern, unless: -> { request.user_agent&.match?(/bot|crawl|spider|facebookexternalhit|Twitterbot|Slackbot|LinkedInBot|Applebot/i) }

  private

  def redirect_www
    if request.host == "www.snowway.app"
      redirect_to "https://snowway.app#{request.fullpath}", status: :moved_permanently, allow_other_host: true
    end
  end
end
