# Black Friday / Cyber Monday deal links on the gear guides that already rank (learnings 2026-11-24).
# Additive box under each guide's short answer; it disappears on its own after Cyber Monday.
# Picks reuse the guide's own gear_link queries, so the box only points at things the page already recommends.
# No prices: sale prices change by the hour.
module BlackFriday
  WINDOW = Date.new(2026, 11, 20)..Date.new(2026, 12, 1)
  BLACK_FRIDAY = Date.new(2026, 11, 27)
  CYBER_MONDAY = Date.new(2026, 11, 30)

  PICKS = {
    "gifts-for-skiers" => [ [ "Heated socks", "fieldsheer premium merino heated socks" ], [ "Rechargeable hand warmers", "ocoopa ut3 pro hand warmer" ], [ "Merino ski socks", "merino ski socks" ], [ "Ski goggles", "ski goggles interchangeable lens" ], [ "Ski boot bags", "ski boot bags" ] ],
    "gifts-for-snowboarders" => [ [ "Heated socks", "fieldsheer premium merino heated socks" ], [ "Snowboard wax kits", "waxing kit" ], [ "Snowboard tools", "snowboard tool" ], [ "Goggles", "ski goggles interchangeable lens" ], [ "Heated mittens", "heated mittens" ] ],
    "best-snowboard-brands" => [ [ "Salomon Highpath", "salomon highpath snowboard" ], [ "CAPiTA Matriarch", "capita matriarch snowboard" ], [ "Burton Cultivator", "burton cultivator snowboard" ], [ "Jones Rally Cat", "jones rally cat snowboard" ] ],
    "best-snowboard-for-beginners" => [ [ "Beginner snowboards", "beginner snowboard" ], [ "Snowboard bindings", "snowboard bindings" ], [ "Snowboard boots", "snowboard boots" ] ],
    "best-ski-brands" => [ [ "Rossignol skis", "rossignol skis" ], [ "Salomon skis", "salomon skis" ], [ "Atomic skis", "atomic skis" ], [ "Völkl skis", "volkl skis" ] ],
    "best-all-mountain-skis" => [ [ "All-mountain skis", "all mountain skis" ], [ "Powder skis", "powder skis" ], [ "Ski bindings", "ski bindings" ] ],
    "best-ski-boots" => [ [ "Ski boots", "ski boots" ], [ "Ski socks", "ski socks" ] ],
    "best-snowboard-boots" => [ [ "Men's snowboard boots", "mens snowboard boots" ], [ "Women's snowboard boots", "womens snowboard boots" ], [ "Dial (BOA) boots", "boa snowboard boots" ] ],
    "best-snowboard-bindings" => [ [ "All-mountain bindings", "snowboard bindings" ], [ "Women's bindings", "womens snowboard bindings" ] ],
    "best-ski-goggles" => [ [ "Goggles with interchangeable lenses", "ski goggles interchangeable lens" ], [ "OTG goggles (over glasses)", "OTG ski goggles" ] ],
    "best-ski-helmet" => [ [ "MIPS ski helmets", "MIPS ski helmet" ], [ "Kids' ski helmets", "kids ski helmet" ] ],
    "best-ski-gloves" => [ [ "Insulated ski mittens", "insulated ski mittens" ], [ "Insulated ski gloves", "insulated ski gloves" ], [ "Glove liners", "glove liners" ] ],
    "snowboard-jacket" => [ [ "Snowboard jackets", "snowboard jacket" ], [ "Women's snowboard jackets", "womens snowboard jacket" ], [ "Insulated ski jackets", "insulated ski jacket" ] ],
    "snowboard-pants" => [ [ "Men's snowboard pants", "mens snowboard pants" ], [ "Women's snowboard pants", "womens snowboard pants" ], [ "Snowboard bibs", "snowboard bibs" ] ],
    "best-ski-pants" => [ [ "Ski bibs", "ski bibs" ], [ "Ski pants", "ski pants" ], [ "Kids' snow pants", "kids snow pants" ] ],
    "best-base-layer-for-skiing" => [ [ "Merino base layers", "merino base layer" ], [ "Synthetic base layers", "synthetic base layer" ] ],
    "best-ski-socks" => [ [ "Merino ski socks", "merino ski socks" ], [ "Lightweight ski socks", "lightweight ski socks" ], [ "Kids' ski socks", "kids ski socks" ] ],
    "best-heated-socks" => [ [ "Hotronic XLP 2P", "hotronic xlp heated socks" ], [ "Gerbing 7V wool socks", "gerbing 7v heated socks" ], [ "Fieldsheer Premium 2.0 Merino", "fieldsheer premium merino heated socks" ], [ "Savior Heat socks", "savior heat heated socks" ] ],
    "best-heated-gloves" => [ [ "Heated ski gloves", "heated ski gloves" ], [ "Heated mittens", "heated mittens" ] ],
    "best-heated-jacket" => [ [ "Heated jackets", "heated jacket" ], [ "Heated vests", "heated vest" ] ],
    "best-hand-warmers" => [ [ "Ignik hand warmers", "ignik hand warmers" ], [ "HotHands", "hothands hand warmers" ], [ "OCOOPA UT3 PRO", "ocoopa ut3 pro hand warmer" ], [ "Zippo HeatBank 6+ Pro", "zippo heatbank 6 pro" ] ],
    "balaclava-vs-ski-mask" => [ [ "Ski balaclavas", "balaclava" ], [ "Neck gaiters", "neck gaiter" ] ]
  }.freeze

  module_function

  def active?(on = Date.current) = WINDOW.cover?(on)
  def picks_for(slug) = active? ? PICKS[slug] : nil
end
