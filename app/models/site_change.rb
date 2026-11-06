# One entry in the change ledger. Title/description changes are SeoOverride rows and revert automatically
# if the page does worse than untouched pages of the same type; content changes get flagged for review.
class SiteChange < ApplicationRecord
  KINDS = %w[title description content].freeze
  STATUSES = %w[proposed live kept reverted needs_review skipped].freeze
  EVALUATE_AFTER = 31.days # 28-day window plus ~3 days for Google's data to settle
  WINDOW = 28

  validates :path, :kind, :status, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }

  scope :recent_first, -> { order(created_at: :desc) }
  scope :due, ->(today = Date.current) { where(status: "live").where(evaluate_on: ..today) }

  def overrides? = kind.in?(%w[title description])

  # Turns a proposal into a live change (or queues it for approval / skips it), per ChangeGuard.
  def self.propose!(path:, kind:, value: nil, reason:, origin: "claude", approved: false)
    change = new(path: path, kind: kind, after_value: value, reason: reason, origin: origin)
    decision = ChangeGuard.decide(path)
    change.result = { "guard" => decision.reason }
    if decision.auto? || (approved && decision.approval?)
      change.go_live!
    else
      change.update!(status: decision.approval? ? "proposed" : "skipped")
    end
    change
  end

  def go_live!(today: Date.current)
    transaction do
      if overrides?
        override = SeoOverride.find_or_initialize_by(path: path)
        self.before_value = override.public_send(kind)
        override.public_send("#{kind}=", after_value)
        override.save!
      end
      self.baseline = PageMetrics.for(path, (today - WINDOW)..(today - 1))
      self.applied_at = Time.current
      self.evaluate_on = today + EVALUATE_AFTER
      self.status = "live"
      save!
    end
  end

  def revert!(note: nil)
    transaction do
      if overrides? && (override = SeoOverride.find_by(path: path))
        override.public_send("#{kind}=", before_value)
        override.title.blank? && override.description.blank? ? override.destroy! : override.save!
      end
      update!(status: overrides? ? "reverted" : "needs_review", decided_at: Time.current, result: (result || {}).merge("note" => note).compact)
    end
  end

  # Compares the page's 28 days after the change with the 28 days before, against the same-type pages
  # nobody changed (traffic swings with the season, so raw before/after would mislead).
  def evaluate!(today: Date.current)
    start = applied_at.to_date
    before = (start - WINDOW)..(start - 1)
    after = start..(start + WINDOW - 1)
    page_before = PageMetrics.for(path, before)
    page_after = PageMetrics.for(path, after)
    controls = control_paths(before, after)
    ctrl_before = PageMetrics.for(controls, before)
    ctrl_after = PageMetrics.for(controls, after)

    metric = page_before["clicks"] >= 10 ? "clicks" : "ctr"
    page_lift = lift(page_before[metric], page_after[metric])
    ctrl_lift = controls.any? ? lift(ctrl_before[metric], ctrl_after[metric]) : 1.0
    worse = page_after[metric] < page_before[metric] && page_lift < ctrl_lift * 0.9

    data = (result || {}).merge("metric" => metric, "page_before" => page_before, "page_after" => page_after,
                                "page_lift" => page_lift.round(3), "control_lift" => ctrl_lift.round(3), "control_pages" => controls.size)
    update!(result: data)
    if worse
      revert!(note: "#{metric} #{pct(page_lift)} vs #{pct(ctrl_lift)} for similar pages")
    else
      update!(status: "kept", decided_at: Time.current, result: data.merge("note" => "#{metric} #{pct(page_lift)} vs #{pct(ctrl_lift)} for similar pages"))
    end
  end

  private

  def control_paths(before, after)
    section = path.split("/").reject(&:blank?).first.to_s
    changed = SiteChange.where(status: %w[live kept reverted needs_review]).where.not(id: id).pluck(:path)
    SearchStat.pages.between(before.first..after.last).where("page LIKE ?", "/#{section}%").where.not(page: [ path, *changed ])
      .group(:page).having("SUM(impressions) >= 50").pluck(:page)
  end

  def lift(before, after)
    before.to_f.positive? ? after.to_f / before.to_f : (after.to_f.positive? ? 2.0 : 1.0)
  end

  def pct(lift)
    "#{lift >= 1 ? "+" : ""}#{((lift - 1) * 100).round}%"
  end
end
