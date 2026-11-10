# 1200x630 share card for non-resort pages (routes, winter towns, month pages, lists, the data study).
# Built only from our own data for a known path, never from request text.
class OgCard < OgImage
  def self.for_path(path)
    fmt = ->(min) { m = (min / 5.0).round * 5; h, mm = m.divmod(60); h.zero? ? "#{mm} min" : (mm.zero? ? "#{h} hr" : "#{h} hr #{mm} min") }
    case path
    when %r{\A/getting-there/([a-z-]+)\z}
      pg = RoutePage.find($1)
      d = pg.drive
      new(kicker: "GETTING THERE", title: pg.title, big: d ? fmt.(d["minutes"]) : "Routes", caption: d ? "by car from #{pg.origin["airport"]}, #{d["miles"]} miles · shuttles and winter driving" : "drive times, shuttles and winter driving")
    when %r{\A/things-to-do-in-([a-z-]+)-in-winter\z}
      t = WinterTown.find($1)
      new(kicker: "WINTER IN #{t.name.upcase}", title: t.title, big: t.activities.size.to_s, caption: "things to do beyond skiing · tours, hot springs, free things")
    when %r{\A/best-places-to-ski-in-([a-z]+)\z}
      m = SkiMonth.find($1)
      r, o = m.ranked.first
      new(kicker: "BEST PLACES TO SKI", title: "in #{m.name} #{m.year}", big: r ? "#{m.powder_days(o)} days" : m.name, caption: r ? "of new snow at #{r.name}, the leader · 10 years measured" : "ranked by snow days")
    when %r{\A/best-ski-resorts-((?:in|on)-[a-z-]+)\z}
      b = BestResorts.find($1)
      r, score, m = b.ranked.first
      new(kicker: "RANKED BY SNOW", title: "Best ski resorts #{b.slug.split("-").first} #{b.name}", big: r.name, caption: "##{1} of #{b.ranked.size} · #{m[:snow_days]} snow days a season, #{number_with_delimiter_safe(m[:vertical])} ft vertical")
    when %r{\A/(epic-pass-price|ikon-pass-price|indy-pass|mountain-collective-pass)\z}
      g = PassGuide.find($1)
      m = g.main
      new(kicker: "SKI PASS GUIDE", title: "#{g.name} #{Date.current.month >= 7 ? Date.current.year : Date.current.year - 1}-#{(Date.current.month >= 7 ? Date.current.year + 1 : Date.current.year) % 100}", big: g.on_sale? ? "$#{number_with_delimiter_safe(m["adult_price_usd"])}" : "Sold out", caption: g.on_sale? ? "adult price · #{m["days"].to_s.truncate(60)}" : "off sale for the season · waitlist only")
    when "/powder-day-odds"
      s = PowderStudy.season.first
      new(kicker: "DATA STUDY", title: "Which ski resorts get new snow most often", big: s ? "#{s[1]} days" : "10 years", caption: s ? "#{s[0].name} leads · #{PowderStudy.season.size} resorts, 10 seasons" : "179 resorts")
    else
      key = TravelList::PAGES.key(path) or raise ActiveRecord::RecordNotFound
      items = TravelList.list(key)
      raise ActiveRecord::RecordNotFound if items.empty?
      titles = { "winter_vacations" => "Best winter vacations in the US", "ski_towns" => "Best ski towns in the US",
                 "beginner_resorts" => "Best ski resorts for beginners", "hot_springs" => "Hot springs in Colorado" }
      captions = { "winter_vacations" => "snowy trips, what to do and where to stay", "ski_towns" => "real mountain towns, ranked",
                   "beginner_resorts" => "learning areas and beginner terrain compared", "hot_springs" => "where to soak, near ski resorts" }
      new(kicker: "SNOW WAY GUIDE", title: titles[key], big: items.size.to_s, caption: captions[key])
    end
  end

  def self.number_with_delimiter_safe(n) = n.to_s.reverse.scan(/\d{1,3}/).join(",").reverse

  def initialize(kicker:, title:, big:, caption:)
    @kicker, @title, @big, @caption = kicker, title, big, caption
  end

  def to_png
    image = Vips::Image.black(WIDTH, HEIGHT, bands: 3).new_from_image(BG).copy(interpretation: :srgb)
    image = draw(image, "SNOW", 72, 56, size: 40, weight: "ExtraBold", color: WHITE)
    image = draw(image, "WAY", 72 + text_width("SNOW", 40, "ExtraBold"), 56, size: 40, weight: "ExtraBold", color: CYAN)
    image = draw(image, @kicker, WIDTH - 72, 64, size: 26, weight: "Bold", color: MUTED, align: :right)
    image = draw(image, @title, 72, 160, size: 62, weight: "Bold", color: WHITE, width: WIDTH - 144)
    image = draw(image, @big, 72, 330, size: @big.length > 11 ? 96 : 140, weight: "ExtraBold", color: CYAN, width: WIDTH - 144)
    image = draw(image, @caption, 72, 510, size: 32, weight: "SemiBold", color: WHITE, width: WIDTH - 144)
    image = draw(image, "snowway.app", WIDTH - 72, 572, size: 28, weight: "SemiBold", color: MUTED, align: :right)
    image.write_to_buffer(".png", compression: 9)
  end
end
