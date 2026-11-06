require "cgi"

# Builds outbound gear and lodging URLs. Plain merchant links until the affiliate IDs are set in ENV,
# then the same links are wrapped for tracking, so pages never need editing when accounts are approved.
module Affiliate
  module_function

  def gear_url(query, merchant: :rei)
    url = case merchant
    when :rei then "https://www.rei.com/search?q=#{CGI.escape(query)}"
    else raise ArgumentError, "unknown merchant #{merchant}"
    end
    avantlink(url, ENV["AVANTLINK_#{merchant.to_s.upcase}_MID"])
  end

  def avantlink(url, merchant_id)
    website_id = ENV["AVANTLINK_WEBSITE_ID"]
    return url if website_id.blank? || merchant_id.blank?

    "https://www.avantlink.com/click.php?tt=cl&mi=#{merchant_id}&pw=#{website_id}&url=#{CGI.escape(url)}"
  end

  def stay22_aid
    ENV["STAY22_AID"].presence
  end

  # Stay22 lodging map centered on a resort; nil until STAY22_AID is configured.
  def stay22_map_url(resort, checkin: Date.current + 2, checkout: Date.current + 5)
    return unless stay22_aid

    "https://www.stay22.com/embed/gm?" + {
      aid: stay22_aid, lat: resort.latitude.to_f, lng: resort.longitude.to_f,
      checkin: checkin.iso8601, checkout: checkout.iso8601, maincolor: "22d3ee", venue: resort.name
    }.to_query
  end
end
