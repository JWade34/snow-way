# Every 15 minutes: publish queued posts that are due. Does nothing until Meta is connected.
# Posts more than 6 hours late are skipped rather than posted stale (e.g. after downtime).
class SocialPublishJob < ApplicationJob
  queue_as :default

  def perform
    return unless MetaPublisher.configured?
    publisher = MetaPublisher.new
    SocialPost.due.limit(5).each do |post|
      if post.scheduled_for < 6.hours.ago
        post.update!(status: "skipped", error: "Missed its slot by more than 6 hours")
        next
      end
      begin
        post.update!(status: "published", result: publisher.publish(post), published_at: Time.current, error: nil)
      rescue => e
        post.update!(status: "failed", error: e.message.to_s.first(500))
      end
    end
  end
end
