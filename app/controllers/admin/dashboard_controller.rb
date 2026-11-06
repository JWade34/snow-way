class Admin::DashboardController < Admin::BaseController
  def show
    @ridden = ResortVisit.count
    @written = ResortVisit.where.not(take: [ nil, "" ]).count
    @published = ResortVisit.published.count
    @gear = GearItem.count
    @gear_public = GearItem.visible.count
    @subscribers = Subscriber.where(unsubscribed_at: nil).distinct.count(:email)
    @recent_subscribers = Subscriber.where(created_at: 7.days.ago..).distinct.count(:email)
  end
end
