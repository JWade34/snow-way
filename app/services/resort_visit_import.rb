# Turns a pasted or dictated list into ResortVisits. Accepts, one per line:
#   Alta: skiers only and the best snow in Utah.     -> marks Alta ridden and saves the take
#   - park in the bottom lot before 8                 -> a tip for the resort on the line above
#   Vail, Beaver Creek, Breck and Keystone            -> marks each ridden
# Nothing is published; Justin reviews each one in the admin area first.
class ResortVisitImport
  ALIASES = {
    "breck" => "breckenridge", "abasin" => "arapahoe-basin", "bird" => "snowbird", "jhole" => "jackson-hole",
    "jackson" => "jackson-hole", "pc" => "park-city", "squaw" => "palisades-tahoe", "palisades" => "palisades-tahoe",
    "mt bachelor" => "mount-bachelor", "whistler" => "whistler-blackcomb", "blackcomb" => "whistler-blackcomb"
  }.freeze
  FILLER = /\b(the|ski|resort|area|mountain|mtn|mt|mount|basin|valley|bowl|and)\b/

  attr_reader :marked, :written, :unmatched

  def initialize(text)
    @text = text.to_s
    @marked = []
    @written = []
    @unmatched = []
  end

  def run!
    current = nil
    @text.each_line do |raw|
      line = raw.strip
      next if line.blank?

      if line.match?(/\A[-•*]\s*/) && current
        add_tip(current, line.sub(/\A[-•*]\s*/, ""))
        next
      end

      line = line.sub(/\A(\d+[.)]|[-•*])\s*/, "")
      name, take = line.split(/:\s*/, 2)
      if take
        current = visit_for(name)
        add_take(current, take) if current
      else
        current = nil
        line.split(/\s*(?:,|;|\band\b|&)\s*/i).each { |n| visit_for(n) if n.present? }
      end
    end
    self
  end

  def match(name)
    key = normalize(name)
    return nil if key.blank?
    slug = ALIASES[key] || ALIASES[name.to_s.downcase.strip]
    return Resort.find_by(slug: slug) if slug

    exact = index[key]
    return exact.first if exact&.one?

    loose = index_loose[loose(name)]
    return loose.first if loose&.one?

    candidates = Resort.all.select { |r| normalize(r.name).start_with?(key) } if key.length >= 4
    candidates&.one? ? candidates.first : nil
  end

  private

  def visit_for(name)
    resort = match(name)
    unless resort
      @unmatched << name.strip
      return nil
    end
    visit = ResortVisit.find_or_create_by!(resort: resort)
    @marked << resort.name unless @marked.include?(resort.name)
    visit
  end

  def add_take(visit, take)
    take = take.strip
    return if take.blank? || visit.take.to_s.include?(take)
    visit.update!(take: [ visit.take.presence, take ].compact.join(" "))
    @written << visit.resort.name unless @written.include?(visit.resort.name)
  end

  def add_tip(visit, tip)
    return if tip.blank? || visit.tips_list.include?(tip)
    visit.update!(tips: [ visit.tips.presence, tip ].compact.join("\n"))
    @written << visit.resort.name unless @written.include?(visit.resort.name)
  end

  def normalize(name)
    I18n.transliterate(name.to_s).downcase.gsub(/[^a-z0-9 ]/, "").squish
  end

  def loose(name)
    normalize(name).gsub(FILLER, "").gsub(" ", "")
  end

  def index
    @index ||= Resort.all.each_with_object(Hash.new { |h, k| h[k] = [] }) do |r, h|
      [ normalize(r.name), normalize(r.slug.tr("-", " ")) ].uniq.each { |k| h[k] << r }
    end
  end

  def index_loose
    @index_loose ||= Resort.all.each_with_object(Hash.new { |h, k| h[k] = [] }) do |r, h|
      [ loose(r.name), loose(r.slug.tr("-", " ")) ].uniq.reject(&:blank?).each { |k| h[k] << r unless h[k].include?(r) }
    end
  end
end
