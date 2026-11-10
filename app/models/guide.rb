# Evergreen how-to articles. Body lives in app/views/guides/_<partial>.html.erb.
class Guide
  ALL = [
    { slug: "how-to-ski", title: "How to Ski: A Beginner's Guide to Your First Day",
      description: "How to ski for the first time: what to book, how to stand, stop and turn, and how to pick a resort and a snow day that make learning easier.",
      keyword: "how to ski" },
    { slug: "what-to-wear-skiing", title: "What to Wear Skiing: A Layer-by-Layer Guide",
      description: "What to wear skiing, from base layer to helmet, plus what to change for cold, snowy, or spring days and what to skip.",
      keyword: "what to wear skiing" },
    { slug: "ski-trip-packing-list", title: "Ski Trip Packing List: Everything to Bring (and Rent)",
      description: "A complete ski trip packing list for flying or driving: clothing, gear, documents, and what to rent at the resort instead of packing.",
      keyword: "ski trip packing list" },
    { slug: "rent-or-buy-ski-gear", title: "Should You Rent or Buy Skis? How to Decide",
      description: "Rent or buy skis and boots? A simple way to decide based on days per year, plus how to get the most out of ski rentals.",
      keyword: "should i rent or buy skis" },
    { slug: "how-to-chase-powder", title: "How to Chase Powder: Plan Ski Trips Around the Forecast",
      description: "How to plan a ski trip around the snow forecast: when to trust a forecast, how far out to book, and how to pick the resort getting the most snow.",
      keyword: "powder day forecast" },
    { slug: "how-to-snowboard", title: "How to Snowboard: A Beginner's Guide to Your First Day",
      description: "How to snowboard for the first time: stance, getting up, the falling leaf, linking turns, and riding the lift, plus how to pick your first day on snow.",
      keyword: "how to snowboard" },
    { slug: "skiing-vs-snowboarding", title: "Skiing vs Snowboarding: Which Should You Learn?",
      description: "Skiing vs snowboarding compared: which is easier to learn, which is harder to master, cost, comfort, and how to choose for your first trip.",
      keyword: "skiing vs snowboarding" },
    { slug: "how-to-wax-skis", title: "How to Wax Skis at Home: Step-by-Step",
      description: "How to wax skis at home: the tools you need, how to choose wax for the temperature, and a step-by-step hot wax, plus how often to do it.",
      keyword: "how to wax skis", affiliate: true },
    { slug: "best-ski-gloves", title: "Best Ski Gloves: How to Pick a Warm, Waterproof Pair",
      description: "How to choose the best ski gloves or mittens: insulation, waterproofing, fit, and features that matter for cold days, spring skiing, and kids.",
      keyword: "best ski gloves", affiliate: true },
    { slug: "best-ski-goggles", title: "Best Ski Goggles: How to Choose Lenses and Fit",
      description: "How to choose the best ski goggles: lens tint and VLT for sun or storms, interchangeable lenses, fog prevention, and helmet fit.",
      keyword: "best ski goggles", affiliate: true },
    { slug: "best-ski-helmet", title: "Best Ski Helmet: How to Choose Size, Fit, and Safety Features",
      description: "How to choose the best ski helmet: sizing, fit checks, safety certifications, MIPS-style rotational protection, venting, and goggle compatibility.",
      keyword: "best ski helmet", affiliate: true },
    { slug: "best-snowboard", title: "Best Snowboard for You: How to Choose Size, Shape, and Flex",
      description: "How to choose the best snowboard: length and width for your size, camber vs rocker, flex, and board shapes for park, powder, and all-mountain.",
      keyword: "best snowboard", affiliate: true },
    { slug: "best-all-mountain-skis", title: "Best All-Mountain Skis: How to Choose Width, Length, and Rocker",
      description: "How to choose the best all-mountain skis: waist width, length, rocker profile, and turn radius for your ability and where you ski.",
      keyword: "best all mountain skis", affiliate: true },
    { slug: "best-ski-boots", title: "Best Ski Boots: How to Choose Fit, Flex, and Size",
      description: "How to choose the best ski boots: mondopoint sizing, last width, flex rating for your ability, and when to see a boot fitter.",
      keyword: "best ski boots", affiliate: true },
    { slug: "best-base-layer-for-skiing", title: "Best Base Layer for Skiing: Merino vs Synthetic",
      description: "How to choose the best base layer for skiing: merino wool vs synthetic, weights for cold and spring days, fit, and what to avoid.",
      keyword: "best base layer for skiing", affiliate: true },
    { slug: "best-ski-pants", title: "Best Ski Pants: How to Choose Waterproofing, Insulation, and Fit",
      description: "How to choose the best ski pants or bibs: waterproof ratings, insulated vs shell, fit over boots, and features worth paying for.",
      keyword: "best ski pants", affiliate: true },
    { slug: "goofy-vs-regular", title: "Goofy vs Regular Snowboard Stance: Which Are You?",
      description: "Goofy vs regular snowboard stance explained: what each means, four quick ways to tell which you are, and how to set your bindings.",
      keyword: "goofy vs regular snowboard" },
    { slug: "camber-vs-rocker", title: "Camber vs Rocker: Which Profile Is Right for You?",
      description: "Camber vs rocker for snowboards and skis: how each profile rides, hybrid options, and which to choose for your ability and terrain.",
      keyword: "camber vs rocker" },
    { slug: "bibs-vs-pants", title: "Bibs vs Pants for Skiing and Snowboarding: Which to Buy",
      description: "Ski and snowboard bibs vs pants: warmth, snow protection, bathroom breaks, fit, and which is better for powder, park, and kids.",
      keyword: "snowboard bibs vs pants", affiliate: true },
    { slug: "ski-gloves-vs-mittens", title: "Ski Gloves vs Mittens: Which Are Warmer?",
      description: "Ski gloves vs mittens compared: warmth, dexterity, lobster and three-finger options, liners, and which to choose for cold hands.",
      keyword: "ski gloves vs mittens", affiliate: true },
    { slug: "balaclava-vs-ski-mask", title: "Balaclava vs Ski Mask vs Neck Gaiter: Which Is Warmest?",
      description: "A balaclava covers your head, ears, neck and face, so it's the warmest; a neck gaiter is the most versatile. How each fits under a helmet and goggles, and which to get.",
      keyword: "balaclava vs ski mask", affiliate: true },
    { slug: "freestyle-vs-freeride-snowboarding", title: "Freestyle vs Freeride vs All-Mountain Snowboarding",
      description: "Freestyle vs freeride vs all-mountain snowboarding: what each style means, the board and setup for each, and which suits you.",
      keyword: "snowboard freestyle vs freeride" },
    { slug: "best-snowboard-boots", title: "Best Snowboard Boots: How to Choose Fit, Flex, and Lacing",
      description: "How to choose snowboard boots for men and women: sizing and fit, flex for your style, traditional vs quick-pull vs BOA lacing, and break-in.",
      keyword: "best snowboard boots", affiliate: true },
    { slug: "best-snowboard-bindings", title: "Best Snowboard Bindings: How to Choose Size, Flex, and Setup",
      description: "How to choose snowboard bindings: sizing to your boots, flex, strap vs rear-entry, mounting compatibility, and stance angles.",
      keyword: "best snowboard bindings", affiliate: true },
    { slug: "best-ski-socks", title: "Best Ski Socks: How to Choose Thickness, Fit, and Material",
      description: "How to choose ski socks: thin vs thick, merino vs synthetic, height and fit in your boots, and why one pair beats two.",
      keyword: "best ski socks", affiliate: true },
    { slug: "snowboard-jacket", title: "Snowboard Jacket Guide: How to Choose Waterproofing and Fit",
      description: "How to choose a snowboard jacket: waterproof and breathability ratings, insulated vs shell, fit, and features like powder skirts and vents.",
      keyword: "snowboard jacket", affiliate: true },
    { slug: "snowboard-pants", title: "Snowboard Pants Guide: How to Choose Fit, Warmth, and Waterproofing",
      description: "How to choose snowboard pants for men and women: fit and length, insulated vs shell, waterproofing, reinforcement, and pants vs bibs.",
      keyword: "snowboard pants", affiliate: true },
    { slug: "best-snowboard-brands", title: "Best Snowboards 2026-27: Top Picks and the Major Brands",
      description: "The best snowboards for 2026-27 by riding style, as picked by Outside, The Good Ride and other reviewers, plus the major brands and the best alternatives to Burton.",
      keyword: "best snowboard brands", affiliate: true },
    { slug: "best-ski-brands", title: "Best Ski Brands for 2026-27 (and Alternatives to Rossignol)",
      description: "The best ski brands for 2026-27: Rossignol, Salomon, Atomic, Völkl, Head, Blizzard and more, what each does best, and the closest alternatives to Rossignol.",
      keyword: "best ski brands", affiliate: true },
    { slug: "what-is-apres-ski", title: "What Is Après-Ski? Meaning, Best Spots and What to Wear",
      description: "Après-ski means after ski in French: drinks, food and hot tubs once the lifts close. Where to go in top ski towns, what to wear, and etiquette.",
      keyword: "apres ski", affiliate: true },
    { slug: "ski-trail-ratings", title: "Ski Trail Ratings: Green, Blue, Black Diamond Explained",
      description: "Green circle is easiest, blue square is intermediate, black diamond is advanced, double black is experts only. What each ski trail rating means and how it varies by resort.",
      keyword: "black diamond ski" },
    { slug: "how-to-ski-moguls", title: "Mogul Skiing: How to Ski Moguls Step by Step",
      description: "How to ski moguls: what bumps are, the line and rhythm to use, absorbing with your legs, pole plants, and drills to get comfortable in mogul fields.",
      keyword: "mogul skiing" },
    { slug: "ski-terms", title: "Ski Terms Glossary: 70+ Words Skiers and Snowboarders Use",
      description: "A glossary of ski and snowboard terms, from après and bluebird to corduroy, crud, sidecountry, and sticks, explained in plain English.",
      keyword: "ski terms" },
    { slug: "how-to-stop-on-skis", title: "How to Stop on Skis: Wedge, Hockey Stop, and More",
      description: "How to stop on skis, from the beginner wedge (pizza) to the hockey stop, plus how to control speed on steeper runs.",
      keyword: "how to stop on skis" },
    { slug: "how-to-ski-powder", title: "How to Ski Powder: Technique and Gear for Deep Snow",
      description: "How to ski powder: stance, turn shape, speed, and the gear that makes deep snow easier, plus safety basics for powder days.",
      keyword: "how to ski powder", affiliate: true },
    { slug: "how-to-carve-on-a-snowboard", title: "How to Turn and Carve on a Snowboard",
      description: "How to turn and carve on a snowboard: from skidded turns to clean carves, edge pressure, body position, and drills to practice.",
      keyword: "how to carve on a snowboard" },
    { slug: "ski-lessons-for-adults", title: "Ski Lessons for Adults: What to Book and What to Expect",
      description: "Ski lessons for adults: group vs private, what a first lesson covers, how long it takes to learn to ski, and how to choose a ski school.",
      keyword: "ski lessons for adults" },
    { slug: "ski-boot-bag", title: "Ski Boot Bags: How to Choose One That Fits Everything",
      description: "How to choose a ski boot bag: size, backpack vs duffel, heated bags, airline carry-on rules, and what to pack in it.",
      keyword: "ski boot bag", affiliate: true },
    { slug: "best-heated-gloves", title: "Heated Gloves for Skiing: Are They Worth It and How to Choose",
      description: "How to choose heated ski gloves and mittens: battery life, heat settings, warmth without power, and who they're worth it for.",
      keyword: "best heated gloves", affiliate: true },
    { slug: "best-heated-socks", title: "Best Heated Socks for Skiing (2026-27): Reviewer Picks",
      description: "The best heated socks for skiing, from Field & Stream and Outdoor Life: Hotronic, Gerbing, Fieldsheer and budget picks, plus battery life and fit tips.",
      keyword: "best heated socks", affiliate: true },
    { slug: "best-hand-warmers", title: "Best Hand Warmers (2026-27): Disposable vs Rechargeable",
      description: "The best hand warmers from GearJunkie and Outdoor Life: Ignik, HotHands, OCOOPA and Zippo, how long each lasts, and the TSA rules for flying.",
      keyword: "best hand warmers", affiliate: true },
    { slug: "how-to-wax-a-snowboard", title: "How to Wax a Snowboard at Home: Step by Step",
      description: "How to wax a snowboard at home: clean, drip and spread hot wax, cool, scrape and brush. Tools, iron temperature, how often to wax, and rub-on wax.",
      keyword: "how to wax a snowboard", affiliate: true },
    { slug: "el-nino-winter-forecast", title: "El Niño Winter 2026-27: What It Means for Ski Season",
      description: "Winter 2026-27 is a strong El Niño. NOAA's outlook and what past strong El Niños meant for snow in each ski region, from the PNW to Utah and California.",
      keyword: "el nino winter forecast" },
    { slug: "best-womens-ski-jacket", title: "Women's Ski Jackets: How to Choose Fit, Warmth, and Waterproofing",
      description: "How to choose a women's ski jacket: women's-specific fit, insulated vs shell, waterproof ratings, length, and features that matter.",
      keyword: "best ski jacket for women", affiliate: true },
    { slug: "best-snowboard-for-beginners", title: "Best Snowboard for Beginners: How to Choose Your First Board",
      description: "How to choose a beginner snowboard: soft flex, rocker or hybrid profiles, the right length and width, and when to rent instead.",
      keyword: "best snowboard for beginners", affiliate: true },
    { slug: "how-to-plan-a-ski-trip", title: "How to Plan a Ski Trip: Step-by-Step Guide",
      description: "How to plan a ski trip: when to go, where to fly, which pass, lodging, rentals, budget, and how to time it around the snow forecast.",
      keyword: "ski trip" },
    { slug: "family-ski-trip", title: "Family Ski Trip Planning: How to Ski With Kids",
      description: "How to plan a family ski trip: picking a family-friendly resort, kids' ski school, gear for kids, lodging, budget, and keeping everyone warm and happy.",
      keyword: "family ski trip" },
    { slug: "ski-in-ski-out", title: "What Is Ski-In/Ski-Out Lodging? Meaning and Is It Worth It",
      description: "Ski-in/ski-out means you can ski from your door to a lift and back. What really counts, how it differs from slopeside, when it's worth the price, and how to find it.",
      keyword: "ski in ski out resorts" },
    { slug: "skiing-with-kids", title: "Skiing With Kids: An Age-by-Age Guide for Parents",
      description: "Skiing with kids by age: when to start, ski school vs teaching them yourself, gear, keeping them warm and happy, and how to plan the day.",
      keyword: "skiing with kids" },
    { slug: "best-family-ski-resorts", title: "Best Family Ski Resorts: How to Choose the Right One",
      description: "How to choose a family ski resort: beginner terrain, ski school, lodging near the lifts, travel time, crowds, and the questions to ask before you book.",
      keyword: "best family ski resorts" },
    { slug: "colorado-ski-resorts-for-families", title: "Best Colorado Ski Resorts for Families (2026-27)",
      description: "The best Colorado ski resorts for families: Keystone, Beaver Creek, Snowmass, Steamboat and more, plus cheaper small hills, I-70 and altitude tips.",
      keyword: "best family ski resorts in colorado" },
    { slug: "utah-ski-resorts-for-families", title: "Best Utah Ski Resorts for Families (2026-27)",
      description: "Utah family ski resorts ranked: Park City, Deer Valley, Snowbasin, Solitude, Brighton and Alta, plus budget picks, canyon traffic and skier-only tips.",
      keyword: "best family ski resorts in utah" },
    { slug: "california-ski-resorts-for-families", title: "Best California Ski Resorts for Families (2026-27)",
      description: "California family ski resorts ranked: Northstar, Mammoth, Palisades Tahoe, Heavenly and more, plus budget picks near LA and chain control tips.",
      keyword: "best family ski resorts in california" },
    { slug: "vermont-ski-resorts-for-families", title: "Best Vermont Ski Resorts for Families (2026-27)",
      description: "Vermont family ski resorts ranked: Smugglers' Notch, Okemo, Stratton, Jay Peak, Stowe and Killington, plus budget picks and cold-weather tips.",
      keyword: "best family ski resorts in vermont" },
    { slug: "ski-trip-drive-or-fly", title: "Drive or Fly to a Ski Resort? How Families Can Decide",
      description: "Should you drive or fly to a ski resort? Decide by hours, family size and cost, compare mountain airports with big hubs, and when to rent skis instead.",
      keyword: "drive or fly to ski resort" },
    { slug: "ski-trip-cost", title: "How Much Does a Ski Trip Cost? 2026-27 Family Budget",
      description: "What a family ski trip costs, line by line: reported 2026-27 lift ticket prices with sources, plus lodging, travel, rentals, lessons, food and savings.",
      keyword: "how much does a ski trip cost" },
    { slug: "kids-ski-packing-list", title: "Kids Ski Trip Packing List: By Age, Plus a Checklist",
      description: "What to pack for kids on a ski trip, toddlers to teens: layers, rent vs pack, helmet and goggle fit, carry-on essentials, and an interactive checklist.",
      keyword: "ski trip packing list for kids", affiliate: true },
    { slug: "winter-driving-to-ski-resorts", title: "Winter Driving to Ski Resorts: Chains, Tires and Rules",
      description: "Driving to ski resorts in winter: Colorado traction law, California R1/R2/R3 chain controls, Utah canyon tire rules, AWD vs snow tires, road apps.",
      keyword: "driving to ski resorts in winter", affiliate: true },
    { slug: "kids-ski-gear", title: "Kids' Ski Gear: What to Buy, What to Rent, and Sizing",
      description: "Kids' ski and snowboard gear guide: helmets, goggles, layers, mittens, boots and skis, seasonal leases, and how to size gear that kids outgrow fast.",
      keyword: "kids ski gear", affiliate: true },
    { slug: "cheap-ski-trip", title: "How to Save Money on a Ski Trip: 20 Practical Ways",
      description: "How to plan a cheap ski trip: when to go, passes vs tickets, lodging, food, rentals, and the easy ways families and first-timers save money.",
      keyword: "cheap ski vacations" },
    { slug: "holiday-ski-trips", title: "Christmas and Spring Break Ski Trips: How to Beat the Crowds",
      description: "Planning a ski trip over Christmas, Presidents' Day, or spring break: when to book, snow odds, crowds, blackout dates, and how families can make it work.",
      keyword: "christmas ski trip" },
    { slug: "all-inclusive-ski-resorts", title: "All-Inclusive Ski Resorts and Trips: What's Included, Where to Go",
      description: "All-inclusive ski resorts and packages in North America: what lodging, lift tickets, lessons and meals are covered, where to go, and when a package beats booking separately.",
      keyword: "all inclusive ski resorts" },
    { slug: "best-heated-jacket", title: "Heated Jackets: Are They Worth It and How to Choose",
      description: "How to choose a heated jacket for skiing and winter: battery life, heat zones, warmth when off, washing, airline rules for batteries, and who they're for.",
      keyword: "heated jacket", affiliate: true },
    { slug: "best-snow-boots", title: "Best Snow Boots: How to Choose Warm, Waterproof Winter Boots",
      description: "How to choose snow boots for men and women: insulation ratings, waterproofing, traction, fit with thick socks, and boots for town vs trail.",
      keyword: "best snow boots", affiliate: true },
    { slug: "ski-rack-roof-box", title: "Ski Racks and Roof Boxes: How to Carry Skis and Boards on Your Car",
      description: "Ski racks vs roof boxes vs hitch racks: how to carry skis and snowboards, fit for your car, capacity, security, and what to know before buying.",
      keyword: "ski rack for car", affiliate: true },
    { slug: "snowshoeing", title: "Snowshoeing for Beginners: How to Start and What You Need",
      description: "How to go snowshoeing: choosing snowshoes by weight and terrain, what to wear, technique on hills, where to go, and winter safety basics.",
      keyword: "snowshoeing", affiliate: true },
    { slug: "cross-country-skiing", title: "Cross-Country Skiing for Beginners: Classic vs Skate",
      description: "How to start cross-country skiing: classic vs skate technique, gear and rentals, where to ski, first-day tips, and how it compares to downhill.",
      keyword: "cross country skiing" },
    { slug: "snowmobiling", title: "Snowmobiling for Beginners: Tours, Rentals, Gear, and Safety",
      description: "How to try snowmobiling: guided tours vs rentals, what to wear, basic riding and safety, avalanche terrain awareness, and how to book a trip.",
      keyword: "snowmobiling" },
    { slug: "snow-tubing", title: "Snow Tubing: How to Find a Tubing Hill and What to Expect",
      description: "Snow tubing guide for families: how to find snow tubing near you, ticket and age basics, what to wear, safety rules, and how it differs from sledding.",
      keyword: "snow tubing near me" },
    { slug: "backcountry-skiing", title: "Backcountry Skiing for Beginners: How to Start Safely",
      description: "How to get into backcountry skiing safely: avalanche education first, essential gear, touring setups, finding partners and guides, and resort sidecountry rules.",
      keyword: "backcountry skiing" },
    { slug: "splitboarding", title: "Splitboarding for Beginners: Gear, Technique, and Safety",
      description: "How splitboarding works: what a splitboard is, bindings and skins, transitions, touring technique, avalanche safety, and how to start with a guide.",
      keyword: "splitboard", affiliate: true },
    { slug: "avalanche-safety-gear", title: "Avalanche Safety Gear: Beacon, Probe, and Shovel Explained",
      description: "What avalanche safety gear you need: transceiver (beacon), probe, and shovel, how they work together, airbag packs, practice, and why training matters most.",
      keyword: "avalanche beacon", affiliate: true },
    { slug: "skiing-in-japan", title: "Skiing in Japan: Best Resorts, When to Go, and Passes",
      description: "Skiing in Japan: when to go for powder, Hokkaido vs Honshu resorts, Epic and Ikon coverage, getting there from Tokyo or Sapporo, and onsen etiquette.",
      keyword: "skiing in japan" },
    { slug: "skiing-in-the-alps", title: "Skiing in the Alps: Best Resorts and How It Differs",
      description: "Skiing in the Alps: the best resorts in France, Switzerland, Austria, and Italy, when to go, airports, Epic and Ikon coverage, and off-piste rules.",
      keyword: "skiing in the alps" },
    { slug: "skiing-in-south-america", title: "Skiing in Chile and Argentina: Season and Resorts",
      description: "Skiing in Chile and Argentina: the June to October season, Tres Valles and Portillo near Santiago, volcano skiing, Bariloche, and which passes work.",
      keyword: "skiing in chile" }
  ].freeze

  attr_reader :slug, :title, :description, :keyword, :affiliate

  def self.all
    ALL.map { |g| new(**g) }
  end

  def self.find(slug)
    all.find { |g| g.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  def initialize(slug:, title:, description:, keyword:, affiliate: false)
    @slug, @title, @description, @keyword, @affiliate = slug, title, description, keyword, affiliate
  end

  def affiliate?
    affiliate
  end

  def to_param
    slug
  end

  def partial
    "guides/#{slug.underscore}"
  end

  DATES_FILE = Rails.root.join("db/guide_dates.yml")

  def self.dates
    @dates = nil if Rails.env.development?
    @dates ||= File.exist?(DATES_FILE) ? YAML.load_file(DATES_FILE) : {}
  end

  def published_on
    Date.parse(self.class.dates.dig(slug, "published") || "2026-11-05")
  end

  def updated_on
    Date.parse(self.class.dates.dig(slug, "updated") || published_on.iso8601)
  end

  # Guides that share a topic with this one, closest topic first.
  def related(limit: 8)
    GuideTopic.all.select { |t| t.guide_slugs.include?(slug) }.flat_map(&:guide_slugs).uniq
      .reject { |s| s == slug }.first(limit).filter_map { |s| Guide.all.find { |g| g.slug == s } }
  end

  CATEGORIES = { "how-to" => "How-to guides", "comparison" => "Comparisons", "gear" => "Gear: how to choose" }.freeze

  HERO = {
    "how-to" => [ "photos/powder-jump-800.webp", 800, 419, "Justin McKelvey snowboarding off a powder jump in the trees" ],
    "comparison" => [ "photos/tree-trail-800.webp", 800, 599, "A snowboarder on a snowy trail between tall pines on a bluebird day" ],
    "gear" => [ "photos/sitting-view-800.webp", 800, 533, "A snowboarder sitting in fresh snow above a valley of snowy ridges" ]
  }.freeze

  def hero
    HERO.fetch(category)
  end

  def category
    return "comparison" if slug.include?("-vs-")
    return "gear" if slug.start_with?("best-") || slug.start_with?("snowboard-jacket", "snowboard-pants")
    "how-to"
  end
end
