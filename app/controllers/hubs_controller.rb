class HubsController < ApplicationController
  def near_me
    totals = Resort.projected_totals
    @resorts = Resort.order(:name).map do |r|
      { n: r.name, s: r.slug, r: r.state_province, la: r.latitude.to_f.round(4), lo: r.longitude.to_f.round(4), t: totals.fetch(r.id, 0.0), p: r.pass_label }
    end
    @hubs = SkiHub.all
  end

  def show
    @hub = SkiHub.find(params[:id])
    @totals = Resort.projected_totals
    @updated_at = SnowForecast.maximum(:created_at)
  end
end
