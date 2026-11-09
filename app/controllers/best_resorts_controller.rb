class BestResortsController < ApplicationController
  def show
    @list = BestResorts.find(params[:id])
    @totals = Resort.projected_totals
    @updated_at = SnowForecast.maximum(:created_at)
  end
end
