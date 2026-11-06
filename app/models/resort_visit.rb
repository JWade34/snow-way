# A resort Justin has ridden. Private until he publishes it; a published visit with a take
# shows as the "take" box on the resort page and in the list on his author page.
class ResortVisit < ApplicationRecord
  belongs_to :resort

  scope :published, -> { where(published: true).where.not(take: [ nil, "" ]) }

  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  def tips_list
    tips.to_s.lines.map { |l| l.strip.delete_prefix("-").delete_prefix("•").strip }.reject(&:blank?)
  end

  def written?
    take.present?
  end
end
