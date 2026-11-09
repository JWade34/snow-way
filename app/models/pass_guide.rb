# 2026-27 ski pass facts for the pass price pages (db/pass_guide.yml, sourced and dated).
class PassGuide
  FILE = Rails.root.join("db/pass_guide.yml")
  PAGES = {
    "epic-pass-price" => { name: "Epic Pass", keys: %w[epic epic_local], resorts: "/epic-pass-resorts", member: ->(r) { r.on_epic? } },
    "ikon-pass-price" => { name: "Ikon Pass", keys: %w[ikon ikon_base], resorts: "/ikon-pass-resorts", member: ->(r) { r.on_ikon? } },
    "indy-pass" => { name: "Indy Pass", keys: %w[indy indy_plus], resorts: "/indy-pass-resorts", member: ->(r) { Array(r.other_passes).include?("indy") } },
    "mountain-collective-pass" => { name: "Mountain Collective", keys: %w[mountain_collective], resorts: "/mountain-collective-resorts", member: ->(r) { Array(r.other_passes).include?("mountain_collective") } }
  }.freeze

  attr_reader :slug

  def self.data
    @data = nil if Rails.env.development?
    @data ||= File.exist?(FILE) ? YAML.load_file(FILE, permitted_classes: [ Date ]) : { "passes" => {} }
  end

  def self.passes = data.fetch("passes", {})
  def self.checked_on = data["checked_on"].to_s
  def self.all = PAGES.keys.map { |s| new(s) }
  def self.find(slug) = PAGES.key?(slug) ? new(slug) : raise(ActiveRecord::RecordNotFound)

  def initialize(slug)
    @slug = slug
  end

  def to_param = slug
  def path = "/#{slug}"
  def page = PAGES.fetch(slug)
  def name = page[:name]
  def variants = page[:keys].filter_map { |k| (p = self.class.passes[k]) && p.merge("key" => k) }
  def main = variants.first
  def on_sale? = main && main["on_sale"] != false
  def resorts_path = page[:resorts]
  def resorts = Resort.all.select(&page[:member])

  # Peak window prices at member resorts we have sourced ticket data for: [[resort, price], ...]
  def window_prices
    resorts.filter_map { |r| (t = LiftTickets.for(r)) && (p = t["window_high"]).to_i.positive? && [ r, p.to_i ] }.sort_by { |_, p| -p }
  end

  def break_even_days
    return unless main && main["adult_price_usd"] && window_prices.any?
    median = window_prices.map(&:last).sort[window_prices.size / 2]
    (main["adult_price_usd"].to_f / median).ceil
  end

  def deadline = main && main["price_deadline"].presence && Date.parse(main["price_deadline"].to_s)
end
