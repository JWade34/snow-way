require "net/http"

# Measured snow on the ground near each resort, from the same hand-picked stations as Powder Day Odds:
# USDA SNOTEL in the West (automated depth sensor), NOAA co-op/CoCoRaHS in the East (observer's morning reading).
# Stores the latest reading from the last 3 days on the resort; anything older is cleared so the page never
# shows a stale number. Station snow is natural snow at one spot, not the resort's groomed or base depth.
module SnowDepth
  module_function

  LOOKBACK_DAYS = 3

  def refresh_all!(as_of = Date.current)
    readings = snotel_readings(as_of).merge(noaa_readings(as_of))
    Resort.find_each do |r|
      depth, on = readings[r.slug]
      r.update_columns(snow_depth_in: depth, snow_depth_on: on)
    end
    readings.size
  end

  # { slug => [inches, date] } for resorts with an approved SNOTEL station. One request covers every station.
  def snotel_readings(as_of)
    by_triplet = Resort.all.filter_map { |r| (st = PowderOdds.station(r)) && [ st["triplet"], r.slug ] }
      .group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
    return {} if by_triplet.empty?

    uri = URI("https://wcc.sc.egov.usda.gov/awdbRestApi/services/v1/data?" + {
      stationTriplets: by_triplet.keys.join(","), elements: "SNWD", duration: "DAILY",
      beginDate: (as_of - LOOKBACK_DAYS).iso8601, endDate: as_of.iso8601 }.to_query)
    body = fetch_json(uri) or return {}
    body.each_with_object({}) do |station, out|
      latest = Array(station.dig("data", 0, "values")).select { |v| v["value"].is_a?(Numeric) && v["value"] >= 0 }.max_by { |v| v["date"] } or next
      Array(by_triplet[station["stationTriplet"]]).each { |slug| out[slug] = [ latest["value"].round, Date.parse(latest["date"]) ] }
    end
  end

  # { slug => [inches, date] } for resorts on a NOAA weather station (no SNOTEL). "T" (trace) counts as 0.
  def noaa_readings(as_of)
    Resort.all.each_with_object({}) do |r, out|
      st = PowderOdds.weather_station(r) or next
      uri = URI("https://data.rcc-acis.org/StnData")
      body = fetch_json(uri, { sid: st["sid"], sdate: (as_of - LOOKBACK_DAYS).iso8601, edate: as_of.iso8601, elems: [ { name: "snwd" } ] }) or next
      latest = Array(body["data"]).reverse.find { |_, v| v == "T" || v.to_s.match?(/\A\d+(\.\d+)?\z/) } or next
      out[r.slug] = [ latest[1] == "T" ? 0 : latest[1].to_f.round, Date.parse(latest[0]) ]
    end
  end

  def fetch_json(uri, post_body = nil)
    res = if post_body
      Net::HTTP.post(uri, post_body.to_json, "Content-Type" => "application/json")
    else
      Net::HTTP.get_response(uri)
    end
    res.is_a?(Net::HTTPSuccess) ? JSON.parse(res.body) : nil
  rescue StandardError => e
    Rails.logger.error("Snow depth fetch failed (#{uri.host}): #{e.message}")
    nil
  end
end
