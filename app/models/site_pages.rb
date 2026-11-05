# Every public, indexable URL. One list feeds the sitemap, /llms.txt, and IndexNow.
module SitePages
  BASE = "https://snowway.app".freeze

  module_function

  def static_paths
    %w[/ /resorts /where-is-it-snowing /ski-resorts /ikon-vs-epic /ski-resort-opening-dates /guides /widget /weather]
  end

  def resort_paths(resorts = Resort.order(:name))
    resorts.flat_map { |r| [ "/resorts/#{r.slug}", "/resorts/#{r.slug}/best-time-to-ski" ] }
  end

  def region_paths
    Region.all.map { |r| "/ski-resorts/#{r.slug}" }
  end

  def hub_paths
    SkiHub.all.map { |h| "/ski-resorts-near/#{h.slug}" }
  end

  def guide_paths
    Guide.all.map { |g| "/guides/#{g.slug}" }
  end

  def all_paths
    static_paths + resort_paths + region_paths + hub_paths + guide_paths
  end

  def url(path)
    "#{BASE}#{path == "/" ? "/" : path}"
  end

  # Pages whose content changes with each forecast refresh.
  def forecast_urls
    (%w[/ /resorts /where-is-it-snowing /ski-resorts /ikon-vs-epic] +
      Resort.order(:name).map { |r| "/resorts/#{r.slug}" } + region_paths + hub_paths).map { |p| url(p) }
  end
end
