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
      keyword: "powder day forecast" }
  ].freeze

  attr_reader :slug, :title, :description, :keyword

  def self.all
    ALL.map { |g| new(**g) }
  end

  def self.find(slug)
    all.find { |g| g.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  def initialize(slug:, title:, description:, keyword:)
    @slug, @title, @description, @keyword = slug, title, description, keyword
  end

  def to_param
    slug
  end

  def partial
    "guides/#{slug.underscore}"
  end
end
