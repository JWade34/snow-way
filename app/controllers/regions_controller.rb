class RegionsController < ApplicationController
  def index
    @regions = Region.all
    @totals = Resort.projected_totals
  end

  def show
    @region = Region.find(params[:id])
    @totals = Resort.projected_totals
    @totals_14 = Resort.projected_totals(days: 14)
    @recent = Resort.recent_totals
    @resorts = @region.resorts.sort_by { |r| [ -@totals.fetch(r.id, 0.0), -@totals_14.fetch(r.id, 0.0), r.name ] }
    @updated_at = SnowForecast.where(resort_id: @resorts.map(&:id)).maximum(:created_at)
  end
end
