require "prawn"
require "prawn/table"

# The free "Powder Calendar" lead magnet: a photo cover, then a month-by-month snow heatmap
# (share of a typical season's snow, Nov–Apr) with pass, opening date, and airport for every resort.
class PowderCalendarPdf
  FONT_DIR = Rails.root.join("vendor/fonts")
  ABOUT_PHOTO = Rails.root.join("vendor/images/justin-roof-rail.jpg")
  MONTHS = [ 11, 12, 1, 2, 3, 4 ].freeze
  CYAN = "22D3EE"
  DEEP = "0891B2"
  DARK = "0F172A"
  MUTED = "64748B"
  # Heat scale for a month's share of the season's snow.
  HEAT = [ [ 20, "0E7490", "FFFFFF" ], [ 15, "06B6D4", "FFFFFF" ], [ 10, "67E8F9", DARK ], [ 5, "CFFAFE", DARK ], [ 0, "F8FAFC", "94A3B8" ] ].freeze

  def initialize(resorts = Resort.north_america.to_a, as_of: Date.current)
    @resorts = resorts.sort_by { |r| [ r.country == "USA" ? 0 : 1, r.state_province, r.name ] }
    @as_of = as_of
  end

  def self.season_label(as_of = Date.current)
    year = as_of.month >= 7 ? as_of.year : as_of.year - 1
    "#{year}-#{(year + 1).to_s.last(2)}"
  end

  def render
    pdf = Prawn::Document.new(page_size: "LETTER", margin: 36, info: { Title: "Snow Way #{season} Powder Calendar", Author: "Snow Way" })
    register_fonts(pdf)
    cover(pdf)
    pdf.start_new_page
    glance(pdf)
    pdf.start_new_page
    about(pdf)
    legend(pdf)
    @resorts.group_by(&:state_province).each do |region, resorts|
      pdf.start_new_page if pdf.cursor < 110
      pdf.move_down 10
      pdf.font("Jakarta", style: :bold) { pdf.text region, size: 13, color: DARK }
      pdf.move_down 4
      heat_table(pdf, resorts)
    end
    footer(pdf)
    pdf.render
  end

  private

  def season = self.class.season_label(@as_of)

  def register_fonts(pdf)
    pdf.font_families.update("Jakarta" => {
      normal: FONT_DIR.join("PlusJakartaSans-Medium.ttf").to_s,
      bold: FONT_DIR.join("PlusJakartaSans-ExtraBold.ttf").to_s
    })
    pdf.font "Jakarta"
  end

  def cover(pdf)
    pdf.canvas do
      w = pdf.bounds.width
      h = pdf.bounds.height
      pdf.fill_color DARK
      pdf.fill_rectangle [ 0, h ], w, h
      # Falling snow (fixed seed so every PDF looks the same)
      rng = Random.new(7)
      pdf.fill_color "FFFFFF"
      140.times do
        pdf.transparent(rng.rand(0.15..0.6)) { pdf.fill_circle [ rng.rand(w), rng.rand((h * 0.3)..h) ], rng.rand(0.6..2.0) }
      end
      ridge = ->(color, points) { pdf.fill_color color; pdf.fill_polygon(*points.map { |x, y| [ x * w, y * h ] }) }
      ridge.("1E3A5F", [ [ 0, 0.30 ], [ 0.12, 0.42 ], [ 0.22, 0.36 ], [ 0.38, 0.55 ], [ 0.52, 0.40 ], [ 0.66, 0.50 ], [ 0.80, 0.38 ], [ 0.92, 0.47 ], [ 1, 0.40 ], [ 1, 0 ], [ 0, 0 ] ])
      ridge.("0E7490", [ [ 0, 0.22 ], [ 0.18, 0.40 ], [ 0.30, 0.31 ], [ 0.46, 0.49 ], [ 0.60, 0.30 ], [ 0.74, 0.43 ], [ 0.88, 0.29 ], [ 1, 0.36 ], [ 1, 0 ], [ 0, 0 ] ])
      # Snowcaps on the front range peaks
      [ [ 0.18, 0.40, 0.05 ], [ 0.46, 0.49, 0.07 ], [ 0.74, 0.43, 0.055 ] ].each do |px, py, size|
        pdf.fill_color "F0FDFF"
        pdf.fill_polygon [ px * w, py * h ], [ (px - size) * w, (py - size * 1.1) * h ], [ (px - size * 0.4) * w, (py - size * 0.8) * h ],
                         [ px * w, (py - size * 1.2) * h ], [ (px + size * 0.45) * w, (py - size * 0.85) * h ], [ (px + size) * w, (py - size * 1.1) * h ]
      end
      ridge.("0F172A", [ [ 0, 0.16 ], [ 0.14, 0.24 ], [ 0.33, 0.17 ], [ 0.50, 0.27 ], [ 0.70, 0.16 ], [ 0.86, 0.23 ], [ 1, 0.18 ], [ 1, 0 ], [ 0, 0 ] ])

      pdf.bounding_box([ 48, h - 56 ], width: w - 96) do
        pdf.formatted_text [ { text: "SNOW", color: "FFFFFF", size: 18, styles: [ :bold ] }, { text: "WAY", color: CYAN, size: 18, styles: [ :bold ] } ]
        pdf.move_down 26
        pdf.font("Jakarta", style: :bold) do
          pdf.text "THE #{season}", size: 16, color: CYAN, character_spacing: 3
          pdf.move_down 2
          pdf.text "Powder", size: 64, color: "FFFFFF", leading: -8
          pdf.text "Calendar", size: 64, color: "FFFFFF"
        end
        pdf.move_down 10
        pdf.text "When the snow really falls at #{@resorts.size} North American ski resorts. Pick your month, pick your mountain, chase the powder.", size: 13, color: "CBD5E1", leading: 3
        pdf.move_down 18
        [ "Month-by-month snow heatmap for every resort", "Early-season, holiday, midwinter, and spring picks", "#{season} opening dates + Epic, Ikon, and Indy access" ].each do |line|
          y = pdf.cursor
          pdf.fill_color CYAN
          pdf.fill_circle [ 4, y - 6 ], 3
          pdf.fill_color "FFFFFF"
          pdf.text_box line, at: [ 16, y ], size: 12, width: w - 120
          pdf.move_down 20
        end
      end
      pdf.fill_color "94A3B8"
      pdf.text_box "Live snow rankings every 6 hours at snowway.app", at: [ 48, 44 ], size: 10, color: "94A3B8", width: w - 96
    end
  end

  def glance(pdf)
    share = ->(r, months) { months.sum { |m| (r.monthly_snow_share || {})[m.to_s].to_f } }
    big = @resorts.select { |r| r.monthly_snow_share && r.vertical_drop.to_i >= 1500 }
    top = ->(months, n = 6) { big.sort_by { |r| -share.(r, months) }.first(n) }
    pdf.font("Jakarta", style: :bold) { pdf.text "Your season at a glance", size: 22, color: DARK }
    pdf.text "Big-mountain picks (1,500+ ft vertical) from 10 seasons of summit snowfall data. % = share of a typical season's snow. Book the month here, then check snowway.app the week before.", size: 10, color: MUTED, leading: 2
    pdf.move_down 12
    cards = [
      [ "Early-season bets", "Biggest share of snow in Nov + Dec", top.([ 11, 12 ]), [ 11, 12 ] ],
      [ "Holiday week", "Snowiest Decembers", top.([ 12 ]), [ 12 ] ],
      [ "Midwinter peak", "Snow most concentrated in Jan + Feb", top.([ 1, 2 ]), [ 1, 2 ] ],
      [ "Spring skiing", "Most snow still falling in Mar + Apr", top.([ 3, 4 ]), [ 3, 4 ] ]
    ]
    col_w = (pdf.bounds.width - 14) / 2
    cards.each_slice(2) do |pair|
      top_y = pdf.cursor
      pair.each_with_index do |(title, sub, list, months), i|
        x = i * (col_w + 14)
        pdf.fill_color "ECFEFF"
        pdf.fill_rounded_rectangle [ x, top_y ], col_w, 128, 8
        pdf.fill_color DARK
        pdf.bounding_box([ x + 12, top_y - 10 ], width: col_w - 24, height: 112) do
          pdf.font("Jakarta", style: :bold) { pdf.text title, size: 13, color: DEEP }
          pdf.text sub, size: 8.5, color: MUTED
          pdf.move_down 5
          list.each_with_index do |r, n|
            pdf.formatted_text [ { text: "#{n + 1}. ", color: MUTED, size: 9.5 }, { text: r.name, color: DARK, size: 9.5, styles: [ :bold ] },
                                 { text: "  #{r.state_province}  ·  #{share.(r, months).round}%", color: MUTED, size: 8.5 } ]
          end
        end
      end
      pdf.move_cursor_to top_y - 140
    end

    pdf.move_down 4
    pdf.font("Jakarta", style: :bold) { pdf.text "Best month to ski, by region", size: 13, color: DARK }
    pdf.move_down 4
    rows = @resorts.group_by(&:state_province).filter_map do |region, rs|
      best = rs.filter_map { |r| r.snowiest_months(1).first&.first }.tally.max_by { |_, n| n }&.first
      [ region, Date::MONTHNAMES[best], rs.size.to_s ] if best
    end
    pdf.fill_color DARK
    half = (rows.size / 2.0).ceil
    top_y = pdf.cursor
    [ rows.first(half), rows.drop(half) ].each_with_index do |chunk, i|
      pdf.bounding_box([ i * (col_w + 14), top_y ], width: col_w) do
        pdf.table([ [ "Region", "Snowiest month", "Resorts" ] ] + chunk, width: col_w, cell_style: { size: 8, padding: [ 2.5, 4 ], border_color: "E2E8F0", border_width: 0.5 }) do |t|
          t.row(0).font_style = :bold
          t.row(0).background_color = "F1F5F9"
        end
      end
    end
  end

  def about(pdf)
    y = pdf.cursor
    pdf.fill_color "0F172A"
    pdf.fill_rounded_rectangle [ 0, y ], pdf.bounds.width, 96, 8
    pdf.fill_color DARK
    pdf.image ABOUT_PHOTO.to_s, at: [ 10, y - 10 ], width: 76, height: 76 if File.exist?(ABOUT_PHOTO)
    pdf.bounding_box([ 100, y - 12 ], width: pdf.bounds.width - 112, height: 76) do
      pdf.font("Jakarta", style: :bold) { pdf.text "Hi, I'm Justin.", size: 13, color: CYAN }
      pdf.text "I ran snowboard and bike shops before I taught myself to code, and I built Snow Way because I was tired of checking ten tabs before booking a trip. "                "I hope this helps you find a deep day. See you on the chair.", size: 9.5, color: "E2E8F0", leading: 2
    end
    pdf.move_cursor_to y - 106
    pdf.fill_color DARK
  end

  def legend(pdf)
    pdf.font("Jakarta", style: :bold) { pdf.text "How to read the calendar", size: 15, color: DARK }
    pdf.move_down 4
    pdf.text "Each cell shows that month's share of a typical season's summit snowfall, from 10 seasons of Open-Meteo historical data (2015–2025). " \
             "Darker means snowier. Use it to pick your month; use snowway.app for this week's forecast. Opening dates are as of #{facts_date} and can change with snow.",
             size: 9, color: MUTED, leading: 2
    pdf.move_down 6
    x = 0
    [ [ "20%+", HEAT[0] ], [ "15–20%", HEAT[1] ], [ "10–15%", HEAT[2] ], [ "5–10%", HEAT[3] ], [ "under 5%", HEAT[4] ] ].each do |label, (_, bg, fg)|
      pdf.fill_color bg
      pdf.fill_rectangle [ x, pdf.cursor ], 64, 16
      pdf.fill_color fg
      pdf.text_box label, at: [ x, pdf.cursor - 3 ], width: 64, align: :center, size: 8.5, color: fg
      x += 70
    end
    pdf.fill_color DARK
    pdf.move_down 24
  end

  def heat_table(pdf, resorts)
    header = [ "Resort" ] + MONTHS.map { |m| Date::ABBR_MONTHNAMES[m] } + [ "Pass", "Opens", "Fly" ]
    rows = resorts.map do |r|
      share = (r.monthly_snow_share || {}).transform_keys(&:to_i)
      [ r.name ] + MONTHS.map { |m| share[m].to_f } + [ short_pass(r), opens(r), r.nearest_airport_code ]
    end
    data = [ header ] + rows.map { |row| row.each_with_index.map { |v, i| (1..6).cover?(i) ? "#{v.round}%" : v } }
    pdf.table(data, header: true, width: pdf.bounds.width,
                    column_widths: { 0 => 150, 7 => 62, 8 => 72, 9 => 36 },
                    cell_style: { size: 8, padding: [ 3.5, 4 ], border_color: "E2E8F0", border_width: 0.5 }) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "F1F5F9"
      t.row(0).text_color = DARK
      (1..6).each { |c| t.column(c).align = :center }
      rows.each_with_index do |row, ri|
        (1..6).each do |c|
          _, bg, fg = HEAT.find { |min, _, _| row[c] >= min }
          cell = t.cells[ri + 1, c]
          cell.background_color = bg
          cell.text_color = fg
        end
      end
    end
  end

  def short_pass(resort)
    labels = []
    labels << "Epic" if resort.on_epic?
    labels << "Ikon" if resort.on_ikon?
    labels << "Indy" if Array(resort.other_passes).include?("indy")
    labels.any? ? labels.join(" + ") : "—"
  end

  def opens(resort)
    return "TBA" unless resort.opening_date
    "#{resort.opening_status == "opened" ? "Open " : ""}#{resort.opening_date.strftime("%b %-d")}"
  end

  def facts_date
    (@resorts.filter_map(&:facts_checked_on).max || @as_of).strftime("%B %-d, %Y")
  end

  def footer(pdf)
    pdf.number_pages "snowway.app  ·  Powder Calendar #{season}  ·  <page>/<total>", at: [ 0, -12 ], size: 8, color: MUTED, align: :center, start_count_at: 1, page_filter: ->(p) { p > 1 }
  end
end
