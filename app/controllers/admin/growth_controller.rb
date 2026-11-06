class Admin::GrowthController < Admin::BaseController
  def show
    @days = params[:days].to_i.presence_in([ 7, 28, 90 ]) || 28
    @report = GrowthReport.trailing(@days)
    @totals = @report.totals
    @prev = @report.previous_totals
    @series = @report.weekly_series
  end
end
