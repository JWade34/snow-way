require "google/apis/searchconsole_v1"
require "googleauth"
require "stringio"

# Pulls daily Google Search Console performance for snowway.app (a domain property).
# Auth: ENV["GSC_SERVICE_ACCOUNT_JSON"], the same service account the McKelvey Hub uses
# (mckelvey-hub-gsc@...), added as a user on the snowway.app property.
class SearchConsole
  SITE = "sc-domain:snowway.app".freeze
  BASE = "https://snowway.app".freeze

  def self.configured?
    ENV["GSC_SERVICE_ACCOUNT_JSON"].present?
  end

  def initialize
    @service = Google::Apis::SearchconsoleV1::SearchConsoleService.new
    @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(ENV.fetch("GSC_SERVICE_ACCOUNT_JSON")),
      scope: "https://www.googleapis.com/auth/webmasters.readonly"
    )
  end

  # Rows for SearchStat.store!: page totals plus page + query rows for each day in range.
  def daily_rows(range)
    rows = fetch(range, %w[date page]).map { |r| row(r, query: "") }
    rows + fetch(range, %w[date page query]).map { |r| row(r, query: r.keys[2].to_s.truncate(255, omission: "")) }
  end

  private

  def fetch(range, dimensions)
    rows = []
    start_row = 0
    loop do
      request = Google::Apis::SearchconsoleV1::SearchAnalyticsQueryRequest.new(
        start_date: range.first.iso8601, end_date: range.last.iso8601, dimensions: dimensions,
        row_limit: 25_000, start_row: start_row, data_state: "all"
      )
      batch = @service.query_searchanalytic(SITE, request).rows || []
      rows.concat(batch)
      break if batch.size < 25_000
      start_row += 25_000
    end
    rows
  end

  def row(r, query:)
    { date: Date.parse(r.keys[0]), source: "google", page: path(r.keys[1]), query: query,
      clicks: r.clicks.to_i, impressions: r.impressions.to_i, position: r.position&.round(2) }
  end

  def path(url)
    url.to_s.sub(%r{\Ahttps?://(www\.)?snowway\.app}, "").presence || "/"
  end
end
