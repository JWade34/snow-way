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
    { slug: "balaclava-vs-ski-mask", title: "Balaclava vs Ski Mask vs Neck Gaiter: What's the Difference?",
      description: "Balaclava vs ski mask vs neck gaiter: what each covers, which is warmest, how they fit with a helmet and goggles, and when to use each.",
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
    { slug: "best-snowboard-brands", title: "Best Snowboard Brands: A Guide to the Major Makers",
      description: "A guide to the major snowboard brands: who makes what, what each is known for, and how to pick a brand for your riding style.",
      keyword: "best snowboard brands", affiliate: true },
    { slug: "best-ski-brands", title: "Best Ski Brands: A Guide to the Major Ski Makers",
      description: "A guide to the major ski brands: where they're from, what each is known for, and how to choose skis by brand for your style.",
      keyword: "best ski brands", affiliate: true },
    { slug: "what-is-apres-ski", title: "What Is Après-Ski? Meaning, Etiquette, and What to Wear",
      description: "What après-ski means, where the tradition comes from, what people do and wear after skiing, and how to enjoy it on your next trip.",
      keyword: "apres ski" },
    { slug: "ski-trail-ratings", title: "Ski Trail Ratings Explained: Green, Blue, Black Diamond",
      description: "Ski trail difficulty ratings explained: green circle, blue square, black diamond, double black diamond, terrain parks, and how ratings vary by resort.",
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
    { slug: "ski-in-ski-out", title: "Ski-In/Ski-Out Lodging: What It Means and Is It Worth It?",
      description: "What ski-in/ski-out really means, how it differs from slopeside and shuttle lodging, when it's worth the price, and how to find it.",
      keyword: "ski in ski out resorts" },
    { slug: "skiing-with-kids", title: "Skiing With Kids: An Age-by-Age Guide for Parents",
      description: "Skiing with kids by age: when to start, ski school vs teaching them yourself, gear, keeping them warm and happy, and how to plan the day.",
      keyword: "skiing with kids" },
    { slug: "best-family-ski-resorts", title: "Best Family Ski Resorts: How to Choose the Right One",
      description: "How to choose a family ski resort: beginner terrain, ski school, lodging near the lifts, travel time, crowds, and the questions to ask before you book.",
      keyword: "best family ski resorts" },
    { slug: "kids-ski-gear", title: "Kids' Ski Gear: What to Buy, What to Rent, and Sizing",
      description: "Kids' ski and snowboard gear guide: helmets, goggles, layers, mittens, boots and skis, seasonal leases, and how to size gear that kids outgrow fast.",
      keyword: "kids ski gear", affiliate: true },
    { slug: "cheap-ski-trip", title: "How to Save Money on a Ski Trip: 20 Practical Ways",
      description: "How to plan a cheap ski trip: when to go, passes vs tickets, lodging, food, rentals, and the easy ways families and first-timers save money.",
      keyword: "cheap ski vacations" },
    { slug: "holiday-ski-trips", title: "Christmas and Spring Break Ski Trips: How to Beat the Crowds",
      description: "Planning a ski trip over Christmas, Presidents' Day, or spring break: when to book, snow odds, crowds, blackout dates, and how families can make it work.",
      keyword: "christmas ski trip" }
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
