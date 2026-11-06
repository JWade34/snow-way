require "prawn"
require "prawn/table"

# Free "Ski Trip Planner" lead magnet: timeline, hub picker, pass guide, budget, forecast tracker, packing list, notes.
class TripPlannerPdf
  FONT_DIR = Rails.root.join("vendor/fonts")
  COVER_PHOTO = Rails.root.join("vendor/images/powder-jump.jpg")
  CYAN = "22D3EE"
  DEEP = "0891B2"
  DARK = "0F172A"
  MUTED = "64748B"

  TIMELINE = [
    [ "3 months out", [ "Pick your month with the Powder Calendar (snowiest months by resort)", "Decide on a pass: Epic, Ikon, Indy, or day tickets (see \"Which pass?\")", "Choose a hub airport with several resorts nearby" ] ],
    [ "6–8 weeks out", [ "Book flights with free changes if you can", "Book lodging with a flexible cancellation policy", "Reserve a 4WD or AWD rental car for mountain roads" ] ],
    [ "2 weeks out", [ "Reserve rentals and lessons (cheaper and faster online)", "Check your gear: tune and wax skis or board, test goggles and gloves", "Buy lift tickets online if you're not on a pass (often cheaper in advance)" ] ],
    [ "7 days out", [ "Watch the 7-day forecast for every resort near your hub", "Note which mountains have storms lined up (snowway.app/where-is-it-snowing)" ] ],
    [ "3 days out", [ "Commit to the resort with the best short-range forecast", "Check road conditions and chain rules for the drive" ] ],
    [ "Night before", [ "Pack with the packing checklist in this planner", "Charge phone, set an early alarm, lay out layers" ] ],
    [ "Powder morning", [ "Be in line before first chair; the best snow goes fast", "Ski the trees and sheltered runs if wind closes the upper lifts" ] ]
  ].freeze

  PASS_GUIDE = [
    [ "Skiing 1–3 days at one resort", "Day tickets, bought online in advance" ],
    [ "Several trips, mostly Vail Resorts mountains", "Epic Pass (or Epic Local if you avoid peak dates)" ],
    [ "Several trips across Alterra and partner mountains", "Ikon Pass (or Ikon Base if you avoid blackouts)" ],
    [ "Smaller, independent mountains and fewer crowds", "Indy Pass" ],
    [ "Chasing storms anywhere", "The pass with the most resorts near your hubs" ]
  ].freeze

  BUDGET = [ "Lift tickets or pass", "Flights", "Lodging", "Rental car / gas / parking", "Ski or snowboard rentals", "Lessons", "Food and drinks", "Gear to buy", "Après and extras" ].freeze

  def render
    pdf = Prawn::Document.new(page_size: "LETTER", margin: 44, info: { Title: "Snow Way Ski Trip Planner", Author: "Snow Way" })
    pdf.font_families.update("Jakarta" => { normal: FONT_DIR.join("PlusJakartaSans-Medium.ttf").to_s, bold: FONT_DIR.join("PlusJakartaSans-ExtraBold.ttf").to_s })
    pdf.font "Jakarta"
    cover(pdf)
    pdf.start_new_page; timeline(pdf)
    pdf.start_new_page; hubs_and_passes(pdf)
    pdf.start_new_page; budget(pdf)
    pdf.start_new_page; packing(pdf)
    pdf.start_new_page; notes(pdf)
    pdf.number_pages "snowway.app  ·  Ski Trip Planner", at: [ 0, -14 ], size: 8, color: MUTED, align: :center, page_filter: ->(p) { p > 1 }
    pdf.render
  end

  private

  def heading(pdf, text, sub = nil)
    pdf.font("Jakarta", style: :bold) { pdf.text text, size: 22, color: DARK }
    pdf.text sub, size: 10, color: MUTED, leading: 2 if sub
    pdf.move_down 12
  end

  def checkbox_line(pdf, text, size: 10.5)
    y = pdf.cursor
    pdf.stroke_color MUTED
    pdf.stroke_rectangle [ 0, y - 1 ], 9, 9
    pdf.fill_color DARK
    pdf.text_box text, at: [ 16, y ], size: size, width: pdf.bounds.width - 16
    pdf.move_down 17
  end

  def cover(pdf)
    pdf.canvas do
      w = pdf.bounds.width
      h = pdf.bounds.height
      pdf.fill_color DARK
      pdf.fill_rectangle [ 0, h ], w, h
      photo_h = w * 733 / 1400.0
      pdf.image COVER_PHOTO.to_s, at: [ 0, h ], width: w if File.exist?(COVER_PHOTO)
      pdf.bounding_box([ 48, h - photo_h - 56 ], width: w - 96) do
        pdf.formatted_text [ { text: "SNOW", color: "FFFFFF", size: 18, styles: [ :bold ] }, { text: "WAY", color: CYAN, size: 18, styles: [ :bold ] } ]
        pdf.move_down 14
        pdf.font("Jakarta", style: :bold) do
          pdf.text "The Ski Trip", size: 52, color: "FFFFFF", leading: -6
          pdf.text "Planner", size: 52, color: CYAN
        end
        pdf.move_down 8
        pdf.fill_color "CBD5E1"
        pdf.text "Plan a powder trip from first idea to first chair: a countdown timeline, the best hub cities, a pass guide, a budget worksheet, and a packing checklist.", size: 12.5, leading: 3, color: "CBD5E1"
      end
      pdf.fill_color "94A3B8"
      pdf.text_box "Print it, fill it in, chase the snow.  ·  snowway.app", at: [ 48, 48 ], size: 10, color: "94A3B8", width: w - 96
    end
  end

  def timeline(pdf)
    heading(pdf, "Plan backward from the snow", "Pick the month from history, the week from the forecast, and commit to a mountain when a storm is about 3 days out.")
    TIMELINE.each do |stage, items|
      pdf.start_new_page if pdf.cursor < 80
      pdf.font("Jakarta", style: :bold) { pdf.text stage.upcase, size: 11, color: DEEP, character_spacing: 1 }
      pdf.move_down 5
      items.each { |item| checkbox_line(pdf, item) }
      pdf.move_down 6
    end
  end

  def hubs_and_passes(pdf)
    heading(pdf, "Pick your hub", "Fly into a city with several resorts nearby so a storm anywhere in the region works for you. Straight-line distance from the airport; drives are longer.")
    hubs = SkiHub.all.sort_by { |hub| -hub.nearby.count { |_, mi| mi <= 120 } }.first(12)
    rows = hubs.map do |hub|
      close = hub.nearby.select { |_, mi| mi <= 120 }
      [ "#{hub.city} (#{hub.airport})", close.size.to_s, hub.nearby.size.to_s, close.first(3).map { |r, _| r.name }.join(", ") ]
    end
    pdf.table([ [ "Hub", "Resorts within 120 mi", "Within 200 mi", "Closest" ] ] + rows, width: pdf.bounds.width,
              column_widths: { 1 => 70, 2 => 62 }, cell_style: { size: 8.5, padding: [ 4, 5 ], border_color: "E2E8F0", border_width: 0.5 }) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "F1F5F9"
    end
    pdf.move_down 20
    heading(pdf, "Which pass?", "A quick rule of thumb. Compare current prices on the official sites before buying.")
    pdf.table([ [ "If you're…", "Look at" ] ] + PASS_GUIDE, width: pdf.bounds.width, cell_style: { size: 9.5, padding: [ 5, 6 ], border_color: "E2E8F0", border_width: 0.5 }) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "F1F5F9"
    end
  end

  def budget(pdf)
    heading(pdf, "Trip budget", "Fill in estimates when you plan and actuals when you're home.")
    rows = BUDGET.map { |item| [ item, "", "" ] } + [ [ "Total", "", "" ] ]
    pdf.table([ [ "Item", "Estimate", "Actual" ] ] + rows, width: pdf.bounds.width, column_widths: { 1 => 110, 2 => 110 },
              cell_style: { size: 10, padding: [ 9, 6 ], border_color: "CBD5E1", border_width: 0.5 }) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "F1F5F9"
      t.row(-1).font_style = :bold
    end
    pdf.move_down 24
    heading(pdf, "7-day forecast tracker", "Check snowway.app each morning the week before. Write in the 7-day snow total for the resorts near your hub.")
    pdf.table([ [ "Resort", "Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7" ] ] + Array.new(6) { [ " " ] * 8 },
              width: pdf.bounds.width, column_widths: { 0 => 150 }, cell_style: { size: 9, padding: [ 9, 4 ], border_color: "CBD5E1", border_width: 0.5 }) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "F1F5F9"
      t.rows(1..-1).height = 28
    end
  end

  def packing(pdf)
    heading(pdf, "Packing checklist")
    PackingChecklistPdf::SECTIONS.each do |section, items|
      pdf.start_new_page if pdf.cursor < 70
      pdf.font("Jakarta", style: :bold) { pdf.text section, size: 11.5, color: DEEP }
      pdf.move_down 4
      items.each { |item| checkbox_line(pdf, item, size: 9.5) }
      pdf.move_down 4
    end
  end

  def notes(pdf)
    heading(pdf, "Trip notes", "Resorts, lodging, confirmation numbers, and the runs you want to hit.")
    pdf.stroke_color "CBD5E1"
    while pdf.cursor > 30
      pdf.stroke_horizontal_rule
      pdf.move_down 26
    end
  end
end
