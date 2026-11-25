# Every public, indexable URL. One list feeds the sitemap, /llms.txt, and IndexNow.
module SitePages
  BASE = "https://snowway.app".freeze

  module_function

  def static_paths
    %w[/ /resorts /where-is-it-snowing /new-england /ski-resorts /ikon-vs-epic /ski-resort-opening-dates /best-ski-resorts-for-christmas /ski-resorts-open-now /ski-pass-blackout-dates /epic-day-pass /christmas-in-aspen /christmas-in-breckenridge /christmas-in-lake-tahoe /christmas-in-vail /christmas-in-park-city /guides /widget /weather
       /snowboard-size-chart /ski-size-chart /ski-boot-size-chart /about /sponsor /authors/justin-mckelvey /affiliate-disclosure
       /epic-pass-resorts /ikon-pass-resorts /indy-pass-resorts /mountain-collective-resorts /epic-pass-price /ikon-pass-price /indy-pass /mountain-collective-pass /powder-report /powder-calendar /ski-trip-planner /ski-resorts-near-me /compare /snowiest-ski-resorts /getting-there /powder-day-odds]
  end

  def resort_paths(resorts = Resort.order(:name))
    resorts.flat_map { |r| [ "/resorts/#{r.slug}", "/resorts/#{r.slug}/best-time-to-ski", "/resorts/#{r.slug}/weather" ] } +
      lodging_paths(resorts) + sitemap_link_paths(resorts)
  end

  # 2026-11-24: webcam and trail-map pages (332, added 11/21, 0 impressions) stay live but out of the sitemap
  # until Dec 23, so Google's small crawl budget for a new, unlinked site goes to the holiday pages first.
  LINK_PAGES_BACK_ON = Date.new(2026, 12, 23)

  def sitemap_link_paths(resorts = Resort.order(:name))
    Date.current >= LINK_PAGES_BACK_ON ? link_paths(resorts) : []
  end

  # Webcam and trail-map pages exist only where the resort publishes them.
  def link_paths(resorts = Resort.order(:name))
    resorts.flat_map do |r|
      links = ResortLinks.for(r)
      [ ("/resorts/#{r.slug}/webcams" if links["webcams"]), ("/resorts/#{r.slug}/trail-map" if links["trail_map"]) ].compact
    end
  end

  def lodging_paths(resorts = Resort.order(:name))
    resorts.select { |r| Lodging.slugs.include?(r.slug) }.map { |r| "/resorts/#{r.slug}/where-to-stay" } +
      resorts.select { |r| LiftTickets.slugs.include?(r.slug) }.map { |r| "/resorts/#{r.slug}/lift-tickets" }
  end

  def comparison_paths
    Comparison.all.map { |c| "/compare/#{c.slug}" }
  end

  def month_paths
    SkiMonth.all.map { |m| "/best-places-to-ski-in-#{m.slug}" } + StateBestTime.all.map { |s| "/best-time-to-ski-in-#{s.slug}" }
  end

  def travel_paths
    TravelList.paths + WinterTown.all.map(&:path) + BestResorts.all.map(&:path)
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
    static_paths + optional_paths + resort_paths + comparison_paths + month_paths + travel_paths + trip_route_paths + region_paths + hub_paths + guide_paths + report_paths
  end

  def url(path)
    "#{BASE}#{path == "/" ? "/" : path}"
  end

  # Pages whose content changes with each forecast refresh.
  def forecast_urls
    (%w[/ /resorts /where-is-it-snowing /new-england /powder-report /ski-resorts /ikon-vs-epic /epic-pass-resorts /ikon-pass-resorts /indy-pass-resorts] +
      Resort.order(:name).flat_map { |r| [ "/resorts/#{r.slug}", "/resorts/#{r.slug}/weather" ] } + region_paths + hub_paths).map { |p| url(p) }
  end
end
