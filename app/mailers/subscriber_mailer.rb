class SubscriberMailer < ApplicationMailer
  helper ApplicationHelper

  # Sent on signup; includes the download link when a PDF was requested.
  def welcome(subscriber, magnet = nil)
    @subscriber = subscriber
    @magnet = LeadMagnetsController::MAGNETS[magnet] && magnet
    @download_url = download_url(@magnet, subscriber) if @magnet
    unsubscribe_headers
    mail to: subscriber.email, subject: @magnet ? "Your #{LeadMagnetsController::MAGNETS[@magnet][:label]} is here ❄️" : "You're on the Snow Way powder alert list ❄️"
  end

  # alerts: [[resort, inches_next_3_days], ...] — first entry is the headline.
  def powder_alert(subscriber, alerts)
    @subscriber = subscriber
    @alerts = alerts
    resort, inches = alerts.first
    unsubscribe_headers
    mail to: subscriber.email, subject: "Powder alert: #{resort.name} forecast #{inches.round}\" in the next 3 days"
  end

  private

  def unsubscribe_headers
    @unsubscribe_url = unsubscribe_url(@subscriber.token)
    headers["List-Unsubscribe"] = "<#{@unsubscribe_url}>"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
  end

  def download_url(magnet, subscriber)
    magnet == "powder-calendar" ? powder_calendar_download_url(subscriber.token) : lead_magnet_download_url(magnet, subscriber.token)
  end
end
