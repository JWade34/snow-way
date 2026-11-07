# Read-only JSON for the weekly improvement loop (Claude). Auth: "Authorization: Bearer $LOOP_API_TOKEN"
# (24+ chars) or the normal admin login. Returns pages, guard verdicts, gaps, and the change ledger.
class Admin::LoopController < Admin::BaseController
  skip_before_action :require_admin
  before_action :require_loop_token

  def show
    report = GrowthReport.trailing(28)
    seo = SeoOverride.all.index_by(&:path)
    render json: {
      generated_at: Time.current, data_through: report.last_synced_on,
      totals: report.totals, previous_totals: report.previous_totals,
      pages: report.pages.first(300).map do |p|
        guard = ChangeGuard.decide(p.path)
        { path: p.path, impressions: p.impressions, clicks: p.clicks, ctr: p.ctr, position: p.position, prev_clicks: p.prev_clicks,
          signups: p.signups, affiliate_clicks: p.affiliate_clicks, winner: p.winner?, opportunity: p.striking_distance?, slipping: p.decaying?,
          guard: guard.verdict, guard_reason: guard.reason, override: seo[p.path]&.slice(:title, :description) }
      end,
      page_queries: SearchStat.queries.where(source: "google").between(report.range).group(:page, :query)
        .having("SUM(impressions) >= 5").pluck(:page, :query, Arel.sql("SUM(impressions)"), Arel.sql("SUM(clicks)"), Arel.sql("SUM(position * impressions) / SUM(impressions)"))
        .sort_by { |r| -r[2] }.first(500).map { |page, q, i, c, pos| { page: page, query: q, impressions: i, clicks: c, position: pos.to_f.round(1) } },
      query_gaps: report.query_gaps(limit: 50),
      ai: { referrals_28d: AiReferral.totals_by_source, top_pages_28d: AiReferral.top_pages,
            citations: AiCitationCheck.latest_run.map { |c| c.slice(:checked_on, :engine, :query, :cited, :mentioned, :snowway_urls, :error) } },
      changes: SiteChange.recent_first.limit(100).as_json(only: %i[path kind after_value reason status result applied_at evaluate_on])
    }
  end

  private

  def require_loop_token
    token = ENV["LOOP_API_TOKEN"].to_s
    supplied = request.authorization.to_s.delete_prefix("Bearer ")
    return if token.length >= 24 && ActiveSupport::SecurityUtils.secure_compare(supplied, token)
    require_admin
  end
end
