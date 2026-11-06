# Justin's gear closet. Everything is private by default; items marked public show on /what-i-ride.
class GearItem < ApplicationRecord
  CATEGORIES = [ "Snowboards", "Bindings", "Boots", "Skis", "Ski boots", "Outerwear", "Layers", "Helmets & goggles",
                 "Gloves & accessories", "Backcountry", "Bags & travel", "Tools & tuning", "Other" ].freeze
  STATUSES = { "riding" => "Riding now", "backup" => "Backup / quiver", "retired" => "Retired", "sold" => "Sold or gave away", "wishlist" => "Wishlist" }.freeze

  validates :model, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES.keys }

  scope :visible, -> { where(public: true) }
  scope :ordered, -> { order(Arel.sql("CASE status WHEN 'riding' THEN 0 WHEN 'backup' THEN 1 WHEN 'wishlist' THEN 2 WHEN 'retired' THEN 3 ELSE 4 END"), :brand, :model) }

  def name
    [ brand, model ].compact_blank.join(" ")
  end

  def status_label
    STATUSES[status]
  end

  def self.by_category(items)
    items.group_by(&:category).sort_by { |cat, _| CATEGORIES.index(cat) || 99 }
  end
end
