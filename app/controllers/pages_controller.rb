class PagesController < ApplicationController
  def where_is_it_snowing
    @totals = Resort.projected_totals
    @recent = Resort.recent_totals
    @resorts = Resort.all.to_a
    @ranked = @resorts.sort_by { |r| -@totals.fetch(r.id, 0.0) }
    @fresh = @resorts.select { |r| @recent.fetch(r.id, 0.0) > 0 }.sort_by { |r| -@recent[r.id] }
    @region_leaders = @resorts.group_by(&:state_province)
      .map { |region, rs| [ region, rs.max_by { |r| @totals.fetch(r.id, 0.0) } ] }
      .select { |_, r| @totals.fetch(r.id, 0.0) > 0 }
      .sort_by { |_, r| -@totals.fetch(r.id, 0.0) }
    @updated_at = SnowForecast.maximum(:created_at)
  end

  def ikon_vs_epic
    @totals = Resort.projected_totals
    resorts = Resort.order(:name).to_a
    @epic = resorts.select(&:on_epic?).sort_by { |r| -@totals.fetch(r.id, 0.0) }
    @ikon = resorts.select(&:on_ikon?).sort_by { |r| -@totals.fetch(r.id, 0.0) }
    @prices = Resort.pass_prices
  end

  def opening_dates
    @totals = Resort.projected_totals
    @resorts = Resort.where.not(opening_date: nil).order(:opening_date, :name)
    @unknown = Resort.where(opening_date: nil).order(:name)
    @checked_on = Resort.maximum(:facts_checked_on)
  end
end
