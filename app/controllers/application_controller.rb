class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Skip for crawlers/bots (iMessage, Facebook, Twitter, etc.) so link previews work
  allow_browser versions: :modern, unless: -> { request.user_agent&.match?(/bot|crawl|spider|facebookexternalhit|Twitterbot|Slackbot|LinkedInBot|Applebot/i) }
end
