# Black Friday ski deals from config/deals/black_friday_2026.yml. Expired deals drop off by themselves.
module BlackFridayDeals
  FILE = Rails.root.join("config/deals/black_friday_2026.yml")
  Deal = Data.define(:retailer, :what, :discount, :code, :ends_on, :ends_note, :url, :source, :source_note)

  module_function

  def data = @data ||= YAML.load_file(FILE, permitted_classes: [ Date ])
  def checked_on = data["checked_on"]
  def season_end = data["cyber_monday_end"]
  def over?(today = Date.current) = today > season_end && passes(today).empty?

  def gear(today = Date.current) = live(data["deals"], today)
  def passes(today = Date.current) = live(data["passes"], today)

  def live(rows, today)
    rows.map { |h| Deal.new(**Deal.members.to_h { |k| [ k, h[k.to_s] ] }) }
        .select { |d| d.ends_on ? today <= d.ends_on : today <= season_end }
        .sort_by { |d| d.ends_on || season_end }
  end
end
