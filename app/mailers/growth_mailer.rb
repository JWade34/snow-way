class GrowthMailer < ApplicationMailer
  # Affiliate programs Justin has applied to. Each drops off the Monday reminder once its
  # env var is set on Railway (i.e. approved and wired in). Add new applications here.
  PENDING_AFFILIATES = [
    { name: "REI (Impact)", env: "REI_IMPACT_LINK", url: "https://app.impact.com" },
    { name: "AvantLink (evo, Backcountry, other shops)", env: "AVANTLINK_WEBSITE_ID", url: "https://classic.avantlink.com" }
  ].freeze

  def self.pending_affiliates
    PENDING_AFFILIATES.reject { |a| ENV[a[:env]].present? }
  end

  def weekly(report = GrowthReport.last_week)
    @report = report
    @totals = report.totals
    @prev = report.previous_totals
    @pages = report.pages
    mail to: ENV.fetch("REPORT_EMAIL", "justin@superdupr.com"),
         subject: "Snow Way week of #{report.range.first.strftime("%b %-d")}: #{@totals[:clicks]} search clicks, #{@totals[:signups]} signups, #{@totals[:affiliate_clicks]} affiliate clicks"
  end
end
