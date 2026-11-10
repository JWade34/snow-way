module AffiliateHelper
  # <%= gear_link "insulated ski gloves", "insulated ski gloves" %> — opens REI search (tracked once AvantLink is set).
  def gear_link(text, query = text, merchant: :auto)
    link_to text, Affiliate.gear_url(query, merchant: merchant), rel: "sponsored nofollow noopener", target: "_blank"
  end

  # Small, quiet disclosure line ending in an underlined link to the policy (same color as the text;
  # the underline is what marks it as a link).
  def affiliate_disclosure(text = nil, css: "mb-6")
    # Amazon requires its sentence wherever its links appear, so it's added to custom text too.
    text = [ text || "Some links on this page are affiliate links. If you buy through them, Snow Way may earn a commission at no extra cost to you.",
             ("As an Amazon Associate, Snow Way earns from qualifying purchases." if Affiliate.amazon_tag) ].compact.join(" ")
    tag.div(class: "#{css} text-[11px] leading-snug text-slate-400") do
      safe_join([ text, " ", link_to("Affiliate disclosure", affiliate_disclosure_path) ])
    end
  end
end
