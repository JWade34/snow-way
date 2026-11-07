require "cgi"

# Builds outbound gear and lodging URLs. Plain merchant links until affiliate IDs are set in ENV;
# then the same links are tracked, so pages never need editing when accounts are approved.
#
# ENV:
#   REI_IMPACT_LINK       REI's Impact tracking link, e.g. https://rei.xxxx.net/c/1234567/123456/12345 (deep links via ?u=)
#   AMAZON_ASSOCIATE_TAG  Amazon Associates tracking tag, e.g. snowway-20
#   AVANTLINK_WEBSITE_ID + AVANTLINK_<MERCHANT>_MID  for AvantLink merchants (evo, etc.)
#   STAY22_AID            Stay22 affiliate ID (lodging map)
module Affiliate
  # When both REI and Amazon are approved, these small accessories go to Amazon; core gear goes to REI.
  AMAZON_ACCESSORIES = /hand warmer|toe warmer|wax|sock|balaclava|gaiter|neck warmer|boot bag|ski strap|tuning|liner glove|glove liner|heated/i

  module_function

  def gear_url(query, merchant: :auto)
    merchant = pick_merchant(query) if merchant == :auto
    case merchant
    when :amazon then amazon_url(query)
    else rei_url(query)
    end
  end

  def pick_merchant(query)
    return :amazon if amazon_tag && (!rei_tracked? || query.match?(AMAZON_ACCESSORIES))
    :rei
  end

  def rei_url(query)
    url = "https://www.rei.com/search?q=#{CGI.escape(query)}"
    impact = ENV["REI_IMPACT_LINK"].presence
    return "#{impact.split("?").first}?u=#{CGI.escape(url)}" if impact
    avantlink(url, ENV["AVANTLINK_REI_MID"])
  end

  def amazon_url(query)
    "https://www.amazon.com/s?k=#{CGI.escape(query)}&tag=#{CGI.escape(amazon_tag)}"
  end

  def rei_tracked?
    ENV["REI_IMPACT_LINK"].present? || (ENV["AVANTLINK_WEBSITE_ID"].present? && ENV["AVANTLINK_REI_MID"].present?)
  end

  def amazon_tag
    ENV["AMAZON_ASSOCIATE_TAG"].presence
  end

  def avantlink(url, merchant_id)
    website_id = ENV["AVANTLINK_WEBSITE_ID"]
    return url if website_id.blank? || merchant_id.blank?

    "https://www.avantlink.com/click.php?tt=cl&mi=#{merchant_id}&pw=#{website_id}&url=#{CGI.escape(url)}"
  end

  # Stay22 affiliate IDs are public (they appear in every tracking link), so the default lives here.
  def stay22_aid
    ENV.fetch("STAY22_AID", "snowway").presence
  end

  # Hotel search near a resort. Booking.com links are converted to Stay22 affiliate links by
  # Let Me Allez (loaded site-wide), so this earns the same as the map. Kayak links do not.
  def hotels_url(resort, checkin: Date.current + 2, checkout: Date.current + 5, place: nil)
    "https://www.booking.com/searchresults.html?" + {
      ss: place || [ resort.name, resort.state_province ].compact.join(", "), checkin: checkin.iso8601, checkout: checkout.iso8601,
      group_adults: 2, no_rooms: 1
    }.to_query
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
