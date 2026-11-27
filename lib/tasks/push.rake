namespace :push do
  # Sends one gear deal notification to devices that opted in to deals (never to powder-alert-only devices).
  #   bin/rails push:deal TITLE="Ski jackets 40% off at REI" BODY="Patagonia and Arc'teryx in the sale" URL="/what-i-ride?utm_campaign=deal"
  # Add DRY_RUN=1 to count devices without sending. URL must be a snowway.app path, so the affiliate link is tracked.
  desc "Send a gear deal notification to devices that opted in"
  task deal: :environment do
    title, body, url = ENV.values_at("TITLE", "BODY", "URL")
    abort "TITLE, BODY and URL (a path starting with /) are required" if [ title, body, url ].any?(&:blank?) || !url.start_with?("/")
    url += (url.include?("?") ? "&" : "?") + "utm_source=push&utm_medium=notification" unless url.include?("utm_source")
    ids = PushSubscription.deal_devices.map(&:id)
    puts "#{ids.size} devices opted in to deals"
    next if ENV["DRY_RUN"].present?
    ids.each { |id| PushDeliveryJob.perform_later(id, title:, body:, url:, tag: "deal", subtitle: "Gear deal", category: "GEAR_DEAL", level: "passive", relevance: 0.2) }
    puts "Queued #{ids.size}"
  end
end
