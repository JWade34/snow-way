class WinterTownsController < ApplicationController
  def show
    @town = WinterTown.find(params[:id])
    @totals = Resort.projected_totals
    @updated_at = SnowForecast.maximum(:created_at)
  end
end
