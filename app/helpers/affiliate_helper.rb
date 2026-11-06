module AffiliateHelper
  # <%= gear_link "insulated ski gloves", "insulated ski gloves" %> — opens REI search (tracked once AvantLink is set).
  def gear_link(text, query = text, merchant: :auto)
    link_to text, Affiliate.gear_url(query, merchant: merchant), rel: "sponsored nofollow noopener", target: "_blank"
  end

  def affiliate_disclosure
    tag.p(class: "text-slate-400 text-xs border-l-2 border-slate-700 pl-3 mb-8") do
      safe_join([ "Some links on this page are affiliate links. If you buy through them, Snow Way may earn a commission at no extra cost to you. ",
                  (Affiliate.amazon_tag ? "As an Amazon Associate, Snow Way earns from qualifying purchases. " : ""),
                  link_to("How this works", affiliate_disclosure_path, class: "underline") ])
    end
  end
end
