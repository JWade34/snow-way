class HubsController < ApplicationController
  def show
    @hub = SkiHub.find(params[:id])
    @totals = Resort.projected_totals
    @updated_at = SnowForecast.maximum(:created_at)
  end
end
