class ResortsController < ApplicationController
  def index
    @resorts = case params[:sort]
    when "name"
      Resort.order(:name)
    when "state"
      Resort.order(:state_province, :name)
    when "recent"
      Resort.by_recent_snow
    else
      Resort.by_most_snow
    end
  end

  def show
    @resort = Resort.includes(:snow_forecasts).find_by(slug: params[:id]) || Resort.find(params[:id])
    @summary = ResortSummary.new(@resort)
    @daily_forecasts = @summary.forecasts
  end
end
