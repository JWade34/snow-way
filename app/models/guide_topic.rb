# Topic hubs at /guides/:topic. A guide can belong to several topics.
class GuideTopic
  TOPICS = {
    "trip-planning" => {
      name: "Ski Trip Planning",
      intro: "Everything for planning a ski trip: when to go, where to fly, which pass, where to stay, what it costs, and how to make it work with kids.",
      guides: %w[how-to-plan-a-ski-trip family-ski-trip skiing-with-kids best-family-ski-resorts cheap-ski-trip holiday-ski-trips
                 all-inclusive-ski-resorts ski-in-ski-out how-to-chase-powder ski-trip-packing-list what-to-wear-skiing what-is-apres-ski]
    },
    "skiing" => {
      name: "Skiing Guides",
      intro: "Learn to ski and get better: first-day basics, stopping, moguls, powder, trail ratings, lessons, and the terms skiers use.",
      guides: %w[how-to-ski how-to-stop-on-skis how-to-ski-moguls how-to-ski-powder ski-lessons-for-adults ski-trail-ratings
                 ski-terms how-to-wax-skis skiing-vs-snowboarding what-to-wear-skiing]
    },
    "snowboarding" => {
      name: "Snowboarding Guides",
      intro: "Learn to snowboard and dial in your setup: first day, turning and carving, stance, riding styles, and choosing a board, boots, and bindings.",
      guides: %w[how-to-snowboard how-to-carve-on-a-snowboard goofy-vs-regular freestyle-vs-freeride-snowboarding camber-vs-rocker
                 best-snowboard-for-beginners best-snowboard best-snowboard-boots best-snowboard-bindings best-snowboard-brands
                 snowboard-jacket snowboard-pants skiing-vs-snowboarding]
    },
    "gear" => {
      name: "Ski & Snowboard Gear Guides",
      intro: "How to choose ski and snowboard gear without overspending: sizing, what matters, what to skip, and when to rent instead of buy.",
      guides: %w[rent-or-buy-ski-gear best-all-mountain-skis best-ski-boots best-ski-brands best-snowboard best-snowboard-for-beginners
                 best-snowboard-boots best-snowboard-bindings best-snowboard-brands best-ski-helmet best-ski-goggles best-ski-gloves
                 best-heated-gloves best-ski-socks best-base-layer-for-skiing best-ski-pants best-womens-ski-jacket snowboard-jacket
                 snowboard-pants ski-boot-bag kids-ski-gear how-to-wax-skis]
    },
    "comparisons" => {
      name: "Ski & Snowboard Comparisons",
      intro: "Head-to-head answers to the questions skiers and snowboarders argue about, each with a side-by-side table.",
      guides: %w[skiing-vs-snowboarding goofy-vs-regular camber-vs-rocker bibs-vs-pants ski-gloves-vs-mittens balaclava-vs-ski-mask
                 freestyle-vs-freeride-snowboarding]
    }
  }.freeze

  attr_reader :slug, :name, :intro

  def self.all
    TOPICS.map { |slug, t| new(slug, t) }
  end

  def self.find(slug)
    all.find { |t| t.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  # The primary topic for a guide's breadcrumb: the first topic that lists it.
  def self.primary_for(guide_slug)
    all.find { |t| t.guide_slugs.include?(guide_slug) }
  end

  def initialize(slug, attrs)
    @slug = slug
    @name = attrs[:name]
    @intro = attrs[:intro]
    @guide_slugs = attrs[:guides]
  end

  attr_reader :guide_slugs

  def guides
    by_slug = Guide.all.index_by(&:slug)
    guide_slugs.filter_map { |s| by_slug[s] }
  end

  def to_param
    slug
  end
end
