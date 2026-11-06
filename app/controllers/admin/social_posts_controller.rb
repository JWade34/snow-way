class Admin::SocialPostsController < Admin::BaseController
  def index
    SocialPlanner.plan_week! if SocialPost.upcoming.none?
    @upcoming = SocialPost.upcoming.where(scheduled_for: ..14.days.from_now)
    @recent = SocialPost.where.not(status: "queued").order(scheduled_for: :desc).limit(20)
    @connected = MetaPublisher.configured?
  end

  def skip
    SocialPost.find(params[:id]).update!(status: "skipped")
    redirect_to admin_social_posts_path, notice: "Skipped."
  end

  def publish
    post = SocialPost.find(params[:id])
    if MetaPublisher.configured?
      post.update!(status: "published", result: MetaPublisher.new.publish(post), published_at: Time.current, error: nil)
      redirect_to admin_social_posts_path, notice: "Posted."
    else
      redirect_to admin_social_posts_path, alert: "Meta isn't connected yet. Save the image and post it by hand."
    end
  rescue MetaPublisher::Error => e
    post.update!(status: "failed", error: e.message)
    redirect_to admin_social_posts_path, alert: "Meta said: #{e.message}"
  end
end
