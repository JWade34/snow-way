require "net/http"
require "json"

# Pulls Bing Webmaster Tools page and query stats. ENV["BING_WEBMASTER_API_KEY"]
# (Bing Webmaster Tools → Settings → API access). Bing reports in roughly weekly buckets,
# so rows land on the bucket's date.
class BingWebmaster
  SITE = "https://snowway.app/".freeze
  API = "https://ssl.bing.com/webmaster/api.svc/json".freeze

  def self.configured?
    ENV["BING_WEBMASTER_API_KEY"].present?
  end

  def daily_rows
    pages = call("GetPageStats").map { |r| row(r, page: path(r["Query"]), query: "") }
    queries = call("GetQueryStats").map { |r| row(r, page: "", query: r["Query"].to_s.truncate(255, omission: "")) }
    pages + queries
  end

  private

  def call(method)
    uri = URI("#{API}/#{method}?siteUrl=#{CGI.escape(SITE)}&apikey=#{ENV.fetch("BING_WEBMASTER_API_KEY")}")
    response = Net::HTTP.get_response(uri)
    raise "Bing #{method} HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body).fetch("d", []) || []
  end

  def row(r, page:, query:)
    { date: Time.at(r["Date"].to_s[/\d+/].to_i / 1000).utc.to_date, source: "bing", page: page, query: query,
      clicks: r["Clicks"].to_i, impressions: r["Impressions"].to_i, position: r["AvgImpressionPosition"]&.to_f&.round(2) }
  end

  def path(url)
    url.to_s.sub(%r{\Ahttps?://(www\.)?snowway\.app}, "").presence || "/"
  end
end
