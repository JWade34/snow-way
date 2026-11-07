# AI visibility: visits arriving from AI assistants, and whether AI answer engines cite snowway.app.
class Admin::AiController < Admin::BaseController
  def show
    @since = 28.days.ago.to_date
    @by_source = AiReferral.totals_by_source(since: @since)
    @top_pages = AiReferral.top_pages(since: @since, limit: 15)
    @checks = AiCitationCheck.latest_run.order(:engine, :query).to_a
    @history = AiCitationCheck.group(:checked_on, :engine).pluck(:checked_on, :engine, Arel.sql("SUM(CASE WHEN cited THEN 1 ELSE 0 END)"), Arel.sql("COUNT(*)")).sort.last(16)
  end
end
