class TripRoutesController < ApplicationController
  def index
    @pages = RoutePage.all
    @totals = Resort.projected_totals
  end

  def show
    @page = RoutePage.find(params[:id])
    @totals = Resort.projected_totals
    @updated_at = SnowForecast.maximum(:created_at)
  end
end
