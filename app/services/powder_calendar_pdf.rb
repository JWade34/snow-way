require "prawn"
require "prawn/table"

# The free "Powder Calendar" lead magnet: snowiest months, opening date, pass, and airport for every resort.
class PowderCalendarPdf
  FONT_DIR = Rails.root.join("vendor/fonts")
  CYAN = "0891B2"
  DARK = "0F172A"
  MUTED = "64748B"

  def initialize(resorts = Resort.order(:country, :state_province, :name).to_a, as_of: Date.current)
    @resorts = resorts.sort_by { |r| [ r.country == "USA" ? 0 : 1, r.state_province, r.name ] }
    @as_of = as_of
  end

  def self.season_label(as_of = Date.current)
    year = as_of.month >= 7 ? as_of.year : as_of.year - 1
    "#{year}-#{(year + 1).to_s.last(2)}"
  end

  def render
    pdf = Prawn::Document.new(page_size: "LETTER", margin: 40, info: { Title: "Snow Way #{season} Powder Calendar", Author: "Snow Way" })
    register_fonts(pdf)
    cover(pdf)
    @resorts.group_by(&:state_province).each do |region, resorts|
      pdf.move_down 14
      pdf.start_new_page if pdf.cursor < 120
      pdf.font("Jakarta", style: :bold) { pdf.text region, size: 14, color: DARK }
      pdf.move_down 6
      pdf.table(rows(resorts), header: true, width: pdf.bounds.width, cell_style: { size: 8.5, padding: [ 4, 5 ], border_color: "E2E8F0" },
                               column_widths: { 0 => 120, 2 => 90, 3 => 120 }) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "F1F5F9"
      end
    end
    footer(pdf)
    pdf.render
  end

  private

  def season = self.class.season_label(@as_of)

  def register_fonts(pdf)
    pdf.font_families.update("Jakarta" => {
      normal: FONT_DIR.join("PlusJakartaSans-Medium.ttf").to_s,
      bold: FONT_DIR.join("PlusJakartaSans-Bold.ttf").to_s
    })
    pdf.font "Jakarta"
  end

  def cover(pdf)
    pdf.formatted_text [ { text: "SNOW", color: DARK, size: 22, styles: [ :bold ] }, { text: "WAY", color: CYAN, size: 22, styles: [ :bold ] } ]
    pdf.move_down 18
    pdf.font("Jakarta", style: :bold) { pdf.text "The #{season} Powder Calendar", size: 26, color: DARK }
    pdf.move_down 6
    pdf.text "Snowiest months, opening dates, passes, and airports for #{@resorts.size} North American ski resorts.", size: 12, color: MUTED
    pdf.move_down 14
    [
      "Snowiest months: the 3 months with the largest share of a typical season's summit snowfall (Open-Meteo historical data, 2015-2025).",
      "Opens: this season's scheduled or actual opening date from resort announcements, as of #{facts_date}. Dates can change with snow.",
      "Pass: Epic or Ikon access for #{season}, from the official pass lists.",
      "For this week's snow, check snowway.app/where-is-it-snowing. It updates every 6 hours."
    ].each { |line| pdf.text "•  #{line}", size: 9.5, color: DARK, leading: 2; pdf.move_down 3 }
  end

  def rows(resorts)
    [ [ "Resort", "Snowiest months (most first)", "Pass", "Opens", "Airport" ] ] + resorts.map do |r|
      [
        r.name,
        r.snowiest_months.map { |m, _| Date::ABBR_MONTHNAMES[m] }.join(", ").presence || "—",
        r.pass_label || "—",
        r.opening_date ? "#{r.opening_status == "opened" ? "Opened " : ""}#{r.opening_date.strftime("%b %-d")}" : "TBA",
        r.nearest_airport_code
      ]
    end
  end

  def facts_date
    (@resorts.filter_map(&:facts_checked_on).max || @as_of).strftime("%B %-d, %Y")
  end

  def footer(pdf)
    pdf.number_pages "snowway.app · Powder Calendar #{season} · page <page> of <total>", at: [ 0, -10 ], size: 8, color: MUTED, align: :center
  end
end
