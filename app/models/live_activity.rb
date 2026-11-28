# A storm tracker running on someone's iPhone Lock Screen for one resort (an iOS Live Activity).
class LiveActivity < ApplicationRecord
  belongs_to :resort
  scope :open, -> { where(ended_at: nil) }
  validates :endpoint, presence: true
end
