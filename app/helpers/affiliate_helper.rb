module AffiliateHelper
  # <%= gear_link "insulated ski gloves", "insulated ski gloves" %> — opens REI search (tracked once AvantLink is set).
  def gear_link(text, query = text, merchant: :auto)
    link_to text, Affiliate.gear_url(query, merchant: merchant), rel: "sponsored nofollow noopener", target: "_blank"
  end

  # Small, quiet disclosure line. The whole sentence links to the policy (a same-color inline link would
  # be indistinguishable from the text, which fails accessibility checks).
  def affiliate_disclosure(text = nil, css: "mb-6")
    text ||= [ "Some links on this page are affiliate links. If you buy through them, Snow Way may earn a commission at no extra cost to you.",
               ("As an Amazon Associate, Snow Way earns from qualifying purchases." if Affiliate.amazon_tag) ].compact.join(" ")
    tag.div(class: "#{css} text-[11px] leading-snug text-slate-400") do
      link_to text, affiliate_disclosure_path, class: "no-underline hover:text-slate-300"
    end
  end
end
