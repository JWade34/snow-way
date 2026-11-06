# An outbound affiliate click, recorded by a beacon from the page (see app/javascript/affiliate_tracking.js).
class AffiliateClick < ApplicationRecord
  MERCHANTS = {
    /rei\.com|\.net\/c\// => "rei", /amazon\./ => "amazon", /avantlink/ => "avantlink", /stay22|booking\.com|expedia|vrbo|hotels\.com/ => "lodging",
    /kayak|skyscanner/ => "flights", /discovercars/ => "cars", /evo\.com/ => "evo", /backcountry\.com/ => "backcountry"
  }.freeze

  def self.merchant_for(href)
    MERCHANTS.find { |pattern, _| href.to_s.match?(pattern) }&.last || URI.parse(href.to_s).host.to_s.delete_prefix("www.").presence || "other"
  rescue URI::InvalidURIError
    "other"
  end
end
