require "csv"

class Admin::SubscribersController < Admin::BaseController
  def index
    @subscribers = Subscriber.includes(:resort).order(created_at: :desc)
    respond_to do |format|
      format.html
      format.csv do
        csv = CSV.generate do |rows|
          rows << %w[email source resort threshold_inches signed_up welcomed unsubscribed]
          @subscribers.each do |s|
            rows << [ s.email, s.source, s.resort&.name, s.threshold_inches, s.created_at.to_date, s.welcomed_at&.to_date, s.unsubscribed_at&.to_date ]
          end
        end
        send_data csv, filename: "snowway-subscribers-#{Date.current}.csv", type: "text/csv"
      end
    end
  end
end
