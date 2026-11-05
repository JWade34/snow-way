class ResortsController < ApplicationController
  before_action :set_resort, only: [ :show, :best_time ]

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
    @summary = ResortSummary.new(@resort)
    @daily_forecasts = @summary.forecasts
  end

  def best_time
    @summary = ResortSummary.new(@resort)
  end

  private

  def set_resort
    @resort = Resort.includes(:snow_forecasts).find_by(slug: params[:id]) || Resort.find(params[:id])
  end
end
