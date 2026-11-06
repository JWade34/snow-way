# The funnel Snow Way optimizes: search impressions → clicks (Google + Bing) → email signups → affiliate clicks.
# Powers the admin Growth tab, the Monday email, and (later) the improvement loops.
class GrowthReport
  PageRow = Struct.new(:path, :impressions, :clicks, :position, :prev_clicks, :signups, :affiliate_clicks, keyword_init: true) do
    def ctr = impressions.positive? ? (clicks * 100.0 / impressions).round(1) : 0.0
    def striking_distance? = position && position.between?(4, 15) && impressions >= 50 && ctr < 3
    def winner? = (position && position <= 3 && clicks >= 5) || (prev_clicks.to_i >= 5 && clicks > prev_clicks * 1.2)
    def decaying? = prev_clicks.to_i >= 20 && clicks < prev_clicks * 0.7
  end

  attr_reader :range, :prev_range

  def initialize(range)
    @range = range
    length = (range.last - range.first).to_i + 1
    @prev_range = (range.first - length)..(range.first - 1)
  end

  # Last complete Monday–Sunday week.
  def self.last_week(today = Date.current)
    sunday = today.beginning_of_week(:monday) - 1
    new((sunday - 6)..sunday)
  end

  def self.trailing(days, today = Date.current)
    new((today - days)..(today - 1))
  end

  def totals(r = range)
    stats = SearchStat.pages.between(r)
    time = r.first.beginning_of_day..r.last.end_of_day
    {
      google_impressions: stats.where(source: "google").sum(:impressions), google_clicks: stats.where(source: "google").sum(:clicks),
      bing_impressions: stats.where(source: "bing").sum(:impressions), bing_clicks: stats.where(source: "bing").sum(:clicks),
      signups: Subscriber.where(created_at: time).distinct.count(:email),
      affiliate_clicks: AffiliateClick.where(created_at: time).count
    }.tap { |t| t[:impressions] = t[:google_impressions] + t[:bing_impressions]; t[:clicks] = t[:google_clicks] + t[:bing_clicks] }
  end

  def previous_totals = totals(prev_range)

  def pages
    @pages ||= begin
      cur = page_stats(range)
      prev = page_stats(prev_range)
      time = range.first.beginning_of_day..range.last.end_of_day
      signups = Subscriber.where(created_at: time).where.not(page_path: nil).group(:page_path).count
      clicks = AffiliateClick.where(created_at: time).group(:page_path).count
      (cur.keys | signups.keys | clicks.keys).map do |path|
        s = cur[path] || {}
        PageRow.new(path: path, impressions: s[:impressions].to_i, clicks: s[:clicks].to_i, position: s[:position],
                    prev_clicks: prev.dig(path, :clicks).to_i, signups: signups[path].to_i, affiliate_clicks: clicks[path].to_i)
      end.sort_by { |p| [ -p.clicks, -p.impressions ] }
    end
  end

  # Searches people use where Snow Way shows up but ranks poorly: candidates for new or better pages.
  def query_gaps(limit: 25)
    SearchStat.queries.between(range).where(source: "google")
      .group(:query).having("SUM(impressions) >= 10")
      .pluck(:query, Arel.sql("SUM(impressions)"), Arel.sql("SUM(clicks)"), Arel.sql("SUM(position * impressions) / SUM(impressions)"))
      .select { |_, _, _, pos| pos.to_f > 10 }
      .sort_by { |_, impr, _, _| -impr }.first(limit)
      .map { |q, impr, clicks, pos| { query: q, impressions: impr, clicks: clicks, position: pos.to_f.round(1) } }
  end

  def top_queries(limit: 15)
    SearchStat.queries.between(range).group(:query)
      .pluck(:query, Arel.sql("SUM(impressions)"), Arel.sql("SUM(clicks)"))
      .sort_by { |_, impr, clicks| [ -clicks, -impr ] }.first(limit)
  end

  def weekly_series(weeks: 8)
    last = self.class.last_week.range.last
    (0...weeks).map { |i| ((last - 6 - (7 * i))..(last - (7 * i))) }.reverse.map { |r| [ r, totals(r) ] }
  end

  def last_synced_on = SearchStat.maximum(:date)

  private

  # Google + Bing page-level totals per path with impression-weighted position (Google only; Bing positions are coarser).
  def page_stats(r)
    SearchStat.pages.between(r).group(:page)
      .pluck(:page, Arel.sql("SUM(impressions)"), Arel.sql("SUM(clicks)"),
             Arel.sql("SUM(CASE WHEN source = 'google' THEN position * impressions END) / NULLIF(SUM(CASE WHEN source = 'google' THEN impressions END), 0)"))
      .to_h { |page, impr, clicks, pos| [ page, { impressions: impr.to_i, clicks: clicks.to_i, position: pos&.to_f&.round(1) } ] }
  end
end
