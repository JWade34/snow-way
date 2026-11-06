# One planned Instagram/Facebook post. SocialPlanner fills the week; SocialPublishJob publishes due posts
# through MetaPublisher once Meta is connected. Until then the queue doubles as a manual posting list in /admin/social.
class SocialPost < ApplicationRecord
  KINDS = %w[report tip brand calendar].freeze
  FORMATS = %w[post story].freeze
  STATUSES = %w[queued published failed skipped].freeze
  HASHTAGS = {
    "report" => "#powderday #skiing #snowboarding #snowforecast #skiseason",
    "family" => "#familyskitrip #skiingwithkids #skifamily #skiing #familytravel",
    "gear" => "#skigear #skiing #snowboarding #skiseason",
    "trip" => "#skitrip #skivacation #skiing #travel",
    "beginner" => "#learntoski #beginnerskier #skiing #snowboarding",
    "powder" => "#powderday #skiing #snowboarding #freshies"
  }.freeze

  validates :kind, inclusion: { in: KINDS }
  validates :format, inclusion: { in: FORMATS }
  validates :status, inclusion: { in: STATUSES }

  scope :due, -> { where(status: "queued").where(scheduled_for: ..Time.current).order(:scheduled_for) }
  scope :upcoming, -> { where(status: "queued").where(scheduled_for: Time.current..).order(:scheduled_for) }

  def tip
    SocialCard.tips.find { |t| t["slug"] == tip_slug } if kind == "tip"
  end

  def story?
    format == "story"
  end

  # Public image URL Meta fetches. Report cards carry the date so caches never serve last week's numbers.
  def image_url(host: "https://snowway.app")
    params = { size: format }
    params[:slug] = tip_slug if tip_slug
    params[:v] = scheduled_for.to_date.iso8601 if kind == "report"
    "#{host}/social/#{kind}.png?#{params.to_query}"
  end

  # Report captions are written at publish time from the live data; the rest are fixed when planned.
  def caption_text(data = nil)
    return caption if caption.present?
    case kind
    when "report" then self.class.report_caption(data || PowderReport.build_data)
    when "tip" then self.class.tip_caption(tip)
    when "calendar" then "The best month for powder at every major ski resort, on one page. Free download, link in bio.\n\n#{HASHTAGS["trip"]}"
    else "Find the most snow. Book the trip. Send it. 7-day snow forecasts for 200+ ski resorts, free. Link in bio.\n\n#{HASHTAGS["report"]}"
    end
  end

  def self.report_caption(data)
    top = data["top"].first(5).select { |r| r["inches"].to_f > 0 }
    return "Quiet week in the forecast. We'll call the next storm as soon as it lines up. Live rankings: link in bio.\n\n#{HASHTAGS["report"]}" if top.empty?
    lines = top.each_with_index.map { |r, i| "#{i + 1}. #{r["name"]} (#{r["region"]}) #{r["inches"].to_f.round}\"" }
    "Where it's dumping this week ❄️\n\n#{lines.join("\n")}\n\n7-day mid-mountain forecasts, updated every 6 hours. Full list: link in bio (snowway.app/powder-report).\n\n#{HASHTAGS["report"]}"
  end

  def self.tip_caption(tip)
    return "" unless tip
    "#{tip["headline"]}\n\n#{tip["bullets"].map { |b| "• #{b}" }.join("\n")}\n\nSave this for your next trip. Full guide: snowway.app/guides/#{tip["guide"]} (link in bio)\n\n#{HASHTAGS.fetch(tip["category"], HASHTAGS["trip"])}"
  end
end
