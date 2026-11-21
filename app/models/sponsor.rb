# A paid, labeled sponsor card for one placement (see db/sponsors.yml). Inactive outside its dates.
class Sponsor
  FILE = Rails.root.join("db/sponsors.yml")
  Card = Struct.new(:name, :headline, :body, :url, :starts_on, :ends_on, keyword_init: true)

  def self.placements
    @placements = nil if Rails.env.development?
    @placements ||= (YAML.load_file(FILE, permitted_classes: [ Date ])["placements"] || {})
  end

  def self.for(placement, today = Date.current)
    attrs = placements[placement] or return
    card = Card.new(**attrs.symbolize_keys.slice(*Card.members))
    return if card.starts_on && today < card.starts_on
    return if card.ends_on && today > card.ends_on
    card
  end
end
