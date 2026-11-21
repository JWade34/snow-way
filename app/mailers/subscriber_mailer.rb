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

  # ranked: [[resort, inches_next_7_days], ...] North America's leaders; mine: the subscriber's own resorts.
  def weekly_report(subscriber, ranked, mine = [])
    @subscriber = subscriber
    @ranked = ranked
    @mine = mine
    @month = SkiMonth.current
    resort, inches = ranked.first
    unsubscribe_headers
    mail to: subscriber.email, subject: "Where it's snowing this week: #{resort.name} leads with #{inches.round}\""
  end

  # Thursday New England forecast for people who signed up on /new-england (Boston Globe readers).
  def new_england_report(subscriber)
    @subscriber = subscriber
    @report = report = NewEnglandReport.new
    lead = report.leader
    unsubscribe_headers
    subject = lead && lead.week > 0 ? "New England ski forecast: #{lead.resort.name} leads with #{lead.week.round(1)}\"" : "New England ski forecast for #{Date.current.strftime("%B %-d")}"
    mail to: subscriber.email, subject: subject
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
