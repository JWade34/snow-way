class SocialPlanJob < ApplicationJob
  queue_as :default

  def perform
    SocialPlanner.plan_week!
  end
end
