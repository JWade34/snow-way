# Every public, indexable URL. One list feeds the sitemap, /llms.txt, and IndexNow.
module SitePages
  BASE = "https://snowway.app".freeze

  module_function

  def static_paths
    %w[/ /resorts /where-is-it-snowing /ski-resorts /ikon-vs-epic /ski-resort-opening-dates /guides /widget /weather
       /snowboard-size-chart /ski-size-chart /ski-boot-size-chart /about /authors/justin-mckelvey /affiliate-disclosure
       /epic-pass-resorts /ikon-pass-resorts /indy-pass-resorts /powder-report /powder-calendar /ski-trip-planner /ski-resorts-near-me /compare /snowiest-ski-resorts /getting-there]
  end

  def resort_paths(resorts = Resort.order(:name))
    resorts.flat_map { |r| [ "/resorts/#{r.slug}", "/resorts/#{r.slug}/best-time-to-ski" ] } + lodging_paths(resorts)
  end

  def lodging_paths(resorts = Resort.order(:name))
    resorts.select { |r| Lodging.slugs.include?(r.slug) }.map { |r| "/resorts/#{r.slug}/where-to-stay" } +
      resorts.select { |r| LiftTickets.slugs.include?(r.slug) }.map { |r| "/resorts/#{r.slug}/lift-tickets" }
  end

  def comparison_paths
    Comparison.all.map { |c| "/compare/#{c.slug}" }
  end

  def month_paths
    SkiMonth.all.map { |m| "/best-places-to-ski-in-#{m.slug}" }
  end

  def trip_route_paths
    RoutePage.all.map { |p| "/getting-there/#{p.slug}" }
  end

  def region_paths
    (Region.all + Region.groups).map { |r| "/ski-resorts/#{r.slug}" }
  end

  def hub_paths
    SkiHub.all.map { |h| "/ski-resorts-near/#{h.slug}" }
  end

  def guide_paths
    GuideTopic.all.map { |t| "/guides/#{t.slug}" } + Guide.all.map { |g| "/guides/#{g.slug}" }
  end

  def report_paths
    PowderReport.order(:week_of).map { |r| "/powder-report/#{r.week_of.iso8601}" }
  end

  # Pages that only exist once Justin publishes something from the admin area.
  def optional_paths
    GearItem.visible.exists? ? [ "/what-i-ride" ] : []
  end

  def all_paths
    static_paths + optional_paths + resort_paths + comparison_paths + month_paths + trip_route_paths + region_paths + hub_paths + guide_paths + report_paths
  end

  def url(path)
    "#{BASE}#{path == "/" ? "/" : path}"
  end

  # Pages whose content changes with each forecast refresh.
  def forecast_urls
    (%w[/ /resorts /where-is-it-snowing /powder-report /ski-resorts /ikon-vs-epic /epic-pass-resorts /ikon-pass-resorts /indy-pass-resorts] +
      Resort.order(:name).map { |r| "/resorts/#{r.slug}" } + region_paths + hub_paths).map { |p| url(p) }
  end
end
