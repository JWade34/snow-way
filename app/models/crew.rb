# A ski crew: a shared link where friends add their pass and see which resorts they can all ski,
# ranked by forecast snow. No accounts: each member is remembered by a cookie on their device.
class Crew < ApplicationRecord
  has_many :members, class_name: "CrewMember", dependent: :destroy
  has_many :push_subscriptions, dependent: :nullify

  MAX_MEMBERS = 30
  ALERT_INCHES = 12 # 3-day forecast at a crew resort that sends a crew powder alert

  before_validation { self.token ||= SecureRandom.alphanumeric(8).downcase }
  validates :name, presence: true, length: { maximum: 40 }
  validates :token, presence: true, uniqueness: true

  def to_param = token

  def passes = members.filter_map(&:pass).uniq.select { |p| Resort::PICKABLE_PASSES.key?(p) }

  # Resorts every member can ski on their own pass. With no passes picked yet, every resort.
  def shared_resorts(pool = Resort.all)
    picked = passes
    pool.to_a.select { |r| picked.all? { |p| r.on_pass?(p) } }
  end

  # [[resort, 7-day inches, 3-day inches], ...] best first. Falls back to all crew passes when nobody overlaps.
  def ranking(limit: 8)
    week, three = Resort.projected_totals(days: 7), Resort.projected_totals(days: 3)
    pool = Resort.where(id: week.keys)
    list = shared_resorts(pool)
    @overlap = list.any? || passes.empty?
    list = pool.to_a.select { |r| passes.any? { |p| r.on_pass?(p) } } unless @overlap
    list.sort_by { |r| -week[r.id].to_f }.first(limit).map { |r| [ r, week[r.id].to_f.round, three[r.id].to_f.round ] }
  end

  def overlap? = @overlap.nil? ? (ranking && @overlap) : @overlap
end
