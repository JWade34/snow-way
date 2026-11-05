class SitemapsController < ApplicationController
  def index
    @resorts = Resort.order(:name)
    @forecast_updated = SnowForecast.group(:resort_id).maximum(:created_at)
    respond_to do |format|
      format.xml
    end
  end
end
