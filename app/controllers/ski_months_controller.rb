class SkiMonthsController < ApplicationController
  def show
    @month = SkiMonth.find(params[:month])
    @ranked = @month.ranked
    @totals = Resort.projected_totals
    @updated_at = SnowForecast.maximum(:created_at)
  end
end
