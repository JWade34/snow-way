class SitemapsController < ApplicationController
  def index
    @resorts = Resort.order(:name)
    @forecast_updated = SnowForecast.group(:resort_id).maximum(:created_at)
    @latest = @forecast_updated.values.max&.to_date || Date.current
    respond_to do |format|
      format.xml
    end
  end
end
