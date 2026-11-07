require "prawn"

# Free printable ski trip packing checklist (lead magnet).
class PackingChecklistPdf
  FONT_DIR = Rails.root.join("vendor/fonts")
  CYAN = "0891B2"
  DARK = "0F172A"
  MUTED = "64748B"

  SECTIONS = {
    "On the mountain" => [ "Ski jacket (waterproof)", "Ski pants or bibs", "Base layer tops and bottoms (merino or synthetic)", "Mid layer (fleece or light puffy)",
                           "Ski socks, one pair per day", "Waterproof gloves or mittens", "Glove liners", "Goggles (plus a low-light lens)", "Helmet (or reserve a rental)",
                           "Neck gaiter or balaclava", "Sunscreen and SPF lip balm", "Hand and toe warmers", "Small backpack or pocket kit: snacks, phone, charger" ],
    "Gear" => [ "Ski or snowboard boots (carry on if you own them)", "Skis or snowboard, or a rental reservation", "Poles", "Lift pass or pass reservations",
                "Boot bag", "Ski straps or board bag" ],
    "Off the mountain" => [ "Waterproof winter boots with good tread", "Warm hat and casual layers", "Swimsuit for the hot tub", "Moisturizer and refillable water bottle",
                            "Medications (including for altitude headaches)" ],
    "Documents and travel" => [ "Driver's license and car rental confirmation (4WD/AWD)", "Lodging confirmation", "Passport if crossing the US–Canada border",
                                "Travel insurance details", "Chains or traction device if required on mountain roads" ],
    "The week before" => [ "Check the 7-day snow forecast (snowway.app)", "Reserve rentals and lessons", "Tune and wax skis or board", "Download the resort trail map" ]
  }.freeze

  # Extra items for each kid, shown in the interactive checklist when "Packing for kids" is on.
  KIDS = [ "Kids' helmet and goggles that fit together", "Two pairs of waterproof mittens per child", "One-piece snowsuit or bibs for little ones",
           "Thin merino or synthetic base layers (no cotton)", "Ski school confirmation and lunch details", "Name labels on gloves, goggles and helmets",
           "Snacks for the lift line and car", "Hand warmers sized for small mittens", "Kids' sunscreen stick and lip balm",
           "Dry change of clothes for after skiing", "Favorite stuffed animal or tablet for the drive or flight" ].freeze

  def render
    pdf = Prawn::Document.new(page_size: "LETTER", margin: 48, info: { Title: "Snow Way Ski Trip Packing Checklist", Author: "Snow Way" })
    pdf.font_families.update("Jakarta" => { normal: FONT_DIR.join("PlusJakartaSans-Medium.ttf").to_s, bold: FONT_DIR.join("PlusJakartaSans-Bold.ttf").to_s })
    pdf.font "Jakarta"
    pdf.formatted_text [ { text: "SNOW", color: DARK, size: 18, styles: [ :bold ] }, { text: "WAY", color: CYAN, size: 18, styles: [ :bold ] } ]
    pdf.move_down 10
    pdf.font("Jakarta", style: :bold) { pdf.text "Ski Trip Packing Checklist", size: 24, color: DARK }
    pdf.text "Print it, check it off, and don't forget the goggles.", size: 11, color: MUTED
    SECTIONS.each do |section, items|
      pdf.move_down 14
      pdf.start_new_page if pdf.cursor < 80
      pdf.font("Jakarta", style: :bold) { pdf.text section, size: 13, color: CYAN }
      pdf.move_down 4
      items.each do |item|
        y = pdf.cursor
        pdf.stroke_color MUTED
        pdf.stroke_rectangle [ 0, y - 1 ], 9, 9
        pdf.text_box item, at: [ 16, y ], size: 10.5, color: DARK, width: pdf.bounds.width - 16
        pdf.move_down 16
      end
    end
    pdf.move_down 10
    pdf.text "Where's the snow this week? snowway.app/where-is-it-snowing", size: 9, color: MUTED
    pdf.render
  end
end
