class GrowthMailer < ApplicationMailer
  def weekly(report = GrowthReport.last_week)
    @report = report
    @totals = report.totals
    @prev = report.previous_totals
    @pages = report.pages
    mail to: ENV.fetch("REPORT_EMAIL", "justin@superdupr.com"),
         subject: "Snow Way week of #{report.range.first.strftime("%b %-d")}: #{@totals[:clicks]} search clicks, #{@totals[:signups]} signups, #{@totals[:affiliate_clicks]} affiliate clicks"
  end
end
