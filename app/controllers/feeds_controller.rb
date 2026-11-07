# Atom feed of new and updated content: weekly powder reports and guides.
class FeedsController < ApplicationController
  def show
    reports = PowderReport.order(week_of: :desc).limit(12).map do |r|
      lead = Array(r.data&.dig("top")).first
      { title: "Powder report, week of #{r.week_of.strftime("%B %-d, %Y")}", url: "https://snowway.app/powder-report/#{r.week_of.iso8601}",
        updated: r.updated_at, summary: lead ? "#{lead["name"]} leads with #{lead["inches"]}\" of snow forecast over the next 7 days." : "This week's North American snow forecast rankings." }
    end
    guides = Guide.all.sort_by { |g| [ -g.updated_on.jd, g.title ] }.map do |g|
      { title: g.title, url: "https://snowway.app/guides/#{g.slug}", updated: g.updated_on.to_time, summary: g.description }
    end
    @entries = (reports + guides).sort_by { |e| -e[:updated].to_i }
    @updated = @entries.map { |e| e[:updated] }.max || Time.current
    render formats: :atom, content_type: "application/atom+xml"
  end
end
