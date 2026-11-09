class PassGuidesController < ApplicationController
  def show
    @guide = PassGuide.find(params[:id])
    @totals = Resort.projected_totals
    @updated_at = SnowForecast.maximum(:created_at)
  end
end
