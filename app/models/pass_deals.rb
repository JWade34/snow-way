# Dated, sourced pass-buying answers for the Black Friday to off-sale window (checked 2026-11-24 on ikonpass.com
# and the Vail Resorts newsroom). Each answer expires with its offer so nothing stale stays on the site.
module PassDeals
  ENTRIES = [
    { until: Date.new(2026, 11, 30), question: "Is there an Ikon Pass Black Friday deal in 2026?",
      answer: "Yes. Ikon's promo code GIFT takes up to $80 off an eligible 2026-27 pass bought on ikonpass.com from November 23 through November 30, 2026 (11:59 pm MT). It can't be combined with other offers. The full Ikon Pass is listed from $1,529 for adults 23+." },
    { until: Date.new(2026, 12, 6), question: "Is there an Epic Pass Black Friday deal in 2026?",
      answer: "Not on the pass itself. Vail Resorts lists the 2026-27 Epic Pass at $1,245 for adults and $995 for young adults (13-30), and the Epic Local Pass at $959 and $759. December 6, 2026 is the last day to buy. The sale is on lodging: Epic Pass holders can save up to 35% on rooms at participating properties in the Lodging Cyber Sale, November 23 to December 7." },
    { until: Date.new(2026, 12, 6), question: "When do Epic Passes go off sale for 2026-27?",
      answer: "After December 6, 2026. Epic Day Passes (1 to 7 days, from $50 to $106 a day) are sold until the same date, per Vail Resorts." }
  ].freeze

  module_function

  def faqs(on = Date.current) = ENTRIES.select { on <= _1[:until] }.map { _1.slice(:question, :answer) }
end
