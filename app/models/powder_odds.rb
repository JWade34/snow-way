# Share of days with 1"+ of fresh snow, by ski-season month (db/powder_odds.yml, from 10 seasons of
# Open-Meteo history via bin/rails resorts:powder_odds). A frequency, not an inch total.
module PowderOdds
  FILE = Rails.root.join("db/powder_odds.yml")

  module_function

  def data
    @data = nil if Rails.env.development?
    @data ||= File.exist?(FILE) ? YAML.load_file(FILE) : {}
  end

  # { 12 => 24, 1 => 29, ... } in season order, or nil.
  def for(resort)
    odds = data.dig("resorts", resort.slug) or return
    resort.ski_season_months.to_h { |m| [ m, odds[m].to_i ] }
  end

  def source
    data["source"]
  end
end
