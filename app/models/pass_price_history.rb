# How Epic and Ikon Pass prices rose through the selling season (db/pass_price_history.yml, sourced and dated).
# Feeds /when-do-ski-pass-prices-go-up: the dates prices went up, how much waiting cost, and when to buy next season.
class PassPriceHistory
  FILE = Rails.root.join("db/pass_price_history.yml")

  Step = Data.define(:date, :label, :adult, :young_adult, :child, :variant_adult, :variant_young_adult, :note, :sources)

  attr_reader :key, :attrs

  def self.data
    @data = nil if Rails.env.development?
    @data ||= YAML.load_file(FILE, permitted_classes: [ Date ])
  end

  def self.all = data.fetch("passes").map { |k, v| new(k, v) }
  def self.find(key) = all.find { |p| p.key == key }
  def self.checked_on = Date.parse(data["checked_on"].to_s)
  def self.season = data["season"].to_s
  def self.general = data.fetch("general", [])

  def self.next_season
    first, = season.split("-").map(&:to_i)
    "#{first + 1}-#{(first + 2) % 100}"
  end

  def initialize(key, attrs)
    @key = key
    @attrs = attrs
  end

  def name = attrs["name"]
  def variant_name = attrs["variant_name"]
  def guide_path = attrs["guide_path"]
  def off_sale_after = attrs["off_sale_after"].presence && Date.parse(attrs["off_sale_after"].to_s)
  def off_sale?(on = Date.current) = off_sale_after.present? && on > off_sale_after

  def steps
    @steps ||= attrs.fetch("steps").map do |s|
      Step.new(date: Date.parse(s["date"].to_s), label: s["label"], adult: s["adult"], young_adult: s["young_adult"], child: s["child"],
               variant_adult: s["variant_adult"], variant_young_adult: s["variant_young_adult"], note: s["note"], sources: Array(s["sources"]))
    end
  end

  def priced(field = :adult) = steps.select { |s| s.public_send(field) }
  def launch(field = :adult) = priced(field).first
  def latest(field = :adult) = priced(field).last

  # How much more a buyer paid by waiting from launch to the latest listed price.
  def rise(field = :adult)
    a, b = launch(field), latest(field)
    return unless a && b && a != b
    diff = b.public_send(field) - a.public_send(field)
    { dollars: diff, percent: (diff * 100.0 / a.public_send(field)).round }
  end

  def sources = steps.flat_map(&:sources).uniq { |s| s["url"] }
end
