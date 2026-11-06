class PagesController < ApplicationController
  def where_is_it_snowing
    @totals = Resort.projected_totals
    @recent = Resort.recent_totals
    @resorts = Resort.north_america.to_a
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
    resorts = Resort.north_america.order(:name).to_a
    @epic = resorts.select(&:on_epic?).sort_by { |r| -@totals.fetch(r.id, 0.0) }
    @ikon = resorts.select(&:on_ikon?).sort_by { |r| -@totals.fetch(r.id, 0.0) }
    @prices = Resort.pass_prices
  end

  def pass_resorts
    @pass = params[:pass].presence_in(%w[epic ikon indy]) || "epic"
    @pass_name = { "epic" => "Epic Pass", "ikon" => "Ikon Pass", "indy" => "Indy Pass" }.fetch(@pass)
    @totals = Resort.projected_totals
    @recent = Resort.recent_totals
    pool = @pass == "indy" ? Resort.all.select { |r| Array(r.other_passes).include?("indy") } : Resort.where(pass: [ @pass, "both" ]).to_a
    na, abroad = pool.partition(&:north_american?)
    @resorts = na.sort_by { |r| [ -@totals.fetch(r.id, 0.0), r.name ] }
    @abroad = abroad.sort_by { |r| [ r.country, r.name ] }
    @prices = Resort.pass_prices
    @updated_at = SnowForecast.maximum(:created_at)
  end

  def about
    @resort_count = Resort.north_america.count
    @international_count = Resort.international.count
  end

  def author
    @guides = Guide.all
  end

  def affiliate_disclosure
  end

  def opening_dates
    @totals = Resort.projected_totals
    @resorts = Resort.north_america.where.not(opening_date: nil).order(:opening_date, :name)
    @unknown = Resort.north_america.where(opening_date: nil).order(:name)
    @checked_on = Resort.maximum(:facts_checked_on)
  end
end
