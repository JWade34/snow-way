# Search numbers for one page (or a set of pages) over a date range, Google + Bing combined.
module PageMetrics
  module_function

  def for(paths, range)
    stats = SearchStat.pages.between(range).where(page: Array(paths))
    impressions = stats.sum(:impressions)
    clicks = stats.sum(:clicks)
    google = stats.where(source: "google")
    gi = google.sum(:impressions)
    position = gi.positive? ? (google.sum(Arel.sql("position * impressions")) / gi).to_f.round(1) : nil
    { "impressions" => impressions, "clicks" => clicks, "ctr" => impressions.positive? ? (clicks * 100.0 / impressions).round(2) : 0.0, "position" => position }
  end
end
