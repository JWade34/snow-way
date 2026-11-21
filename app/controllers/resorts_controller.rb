class ResortsController < ApplicationController
  before_action :set_resort, only: [ :show, :best_time, :where_to_stay, :lift_tickets, :weather, :webcams, :trail_map ]

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

  def lift_tickets
    @tickets = LiftTickets.for(@resort) or raise ActiveRecord::RecordNotFound
    @summary = ResortSummary.new(@resort)
  end

  # "[resort] weather": hourly and 7-day mountain weather (searched 3-5x more than "snow report").
  def weather
    @summary = ResortSummary.new(@resort)
  end

  # Only for resorts with an official webcam / trail map link (db/resort_links.yml).
  def webcams
    @links = ResortLinks.for(@resort)
    raise ActiveRecord::RecordNotFound unless @links["webcams"]
    @summary = ResortSummary.new(@resort)
  end

  def trail_map
    @links = ResortLinks.for(@resort)
    raise ActiveRecord::RecordNotFound unless @links["trail_map"]
    @summary = ResortSummary.new(@resort)
  end

  private

  def set_resort
    @resort = Resort.includes(:snow_forecasts).find_by(slug: params[:id]) || Resort.find(params[:id])
  end
end
