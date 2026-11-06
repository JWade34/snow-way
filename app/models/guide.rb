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
      keyword: "best ski pants", affiliate: true }
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
end
