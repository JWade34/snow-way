class CrewMember < ApplicationRecord
  belongs_to :crew
  validates :member_token, presence: true, uniqueness: { scope: :crew_id }
  validates :name, length: { maximum: 30 }
  validates :pass, inclusion: { in: Resort::PICKABLE_PASSES.keys + [ "none" ] }, allow_nil: true

  def pass_label = Resort::PICKABLE_PASSES[pass] || "No pass"
  def display_name = name.presence || "A skier"
end
