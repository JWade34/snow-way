# Decides whether the loop may change a page on its own. Justin's rule: automatic only on low-traffic
# pages, only to improve them, never touching what already works.
module ChangeGuard
  MIN_IMPRESSIONS_14D = 100   # below this there's too little data to judge a change
  HIGH_TRAFFIC_CLICKS_28D = 30 # at or above this, Justin approves first
  COOLDOWN = 28.days           # one change per page at a time

  Decision = Struct.new(:verdict, :reason) do
    def auto? = verdict == :auto
    def approval? = verdict == :approval
  end

  module_function

  def decide(path, today: Date.current)
    if SiteChange.where(path: path, status: %w[live proposed]).exists? || SiteChange.where(path: path).where("applied_at > ?", COOLDOWN.ago).exists?
      return Decision.new(:blocked, "already has a change being measured")
    end

    recent = PageMetrics.for(path, (today - 14)..(today - 1))
    month = PageMetrics.for(path, (today - 28)..(today - 1))
    prior = PageMetrics.for(path, (today - 56)..(today - 29))
    return Decision.new(:blocked, "not enough data (#{recent["impressions"]} impressions in 14 days, need #{MIN_IMPRESSIONS_14D})") if recent["impressions"] < MIN_IMPRESSIONS_14D

    winner = (month["position"] && month["position"] <= 3 && month["clicks"] >= 5) || (prior["clicks"] >= 5 && month["clicks"] > prior["clicks"] * 1.2)
    return Decision.new(:approval, "protected: this page is working (top 3 or growing)") if winner
    return Decision.new(:approval, "high traffic (#{month["clicks"]} clicks in 28 days)") if month["clicks"] >= HIGH_TRAFFIC_CLICKS_28D

    Decision.new(:auto, "low traffic, not a winner")
  end
end
