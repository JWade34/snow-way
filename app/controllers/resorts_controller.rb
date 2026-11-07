class ResortsController < ApplicationController
  before_action :set_resort, only: [ :show, :best_time, :where_to_stay ]

  def index
    @resorts = case params[:sort]
    when "name"
      Resort.north_america.order(:name)
    when "state"
      Resort.north_america.order(:state_province, :name)
    when "recent"
      Resort.north_america.by_recent_snow
    else
      Resort.north_america.by_most_snow
    end
  end

  def show
    @summary = ResortSummary.new(@resort)
    @daily_forecasts = @summary.forecasts
  end

  def best_time
    @summary = ResortSummary.new(@resort)
  end

  def where_to_stay
    @lodging = Lodging.for(@resort) or raise ActiveRecord::RecordNotFound
    @summary = ResortSummary.new(@resort)
  end

  private

  def set_resort
    @resort = Resort.includes(:snow_forecasts).find_by(slug: params[:id]) || Resort.find(params[:id])
  end
end
