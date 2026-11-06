# Weekly (Monday, before the report): keep or revert every change whose 28-day measurement window is done.
class SiteChangeEvaluateJob < ApplicationJob
  queue_as :default

  def perform
    SiteChange.due.find_each do |change|
      change.evaluate!
    rescue StandardError => e
      Rails.logger.error "[SiteChangeEvaluate] change #{change.id} failed: #{e.class}: #{e.message}"
    end
  end
end
