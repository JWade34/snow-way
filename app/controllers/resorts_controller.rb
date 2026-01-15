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
    @resort = Resort.find_by(slug: params[:id]) || Resort.find(params[:id])
    @daily_forecasts = @resort.snow_forecasts.where(forecast_date: Date.today..7.days.from_now).order(:forecast_date)
  end
end
