require "vips"

# Instagram-sized graphics in the Snow Way look (dark slate, falling snow, cyan + amber).
#   SocialCard.new(:report, format: :post).to_png   # this week's snowiest resorts, live data
#   SocialCard.new(:brand, format: :story).to_png
# Formats: post 1080x1350 (Instagram portrait), square 1080x1080, story 1080x1920.
class SocialCard
  FORMATS = { post: [ 1080, 1350 ], square: [ 1080, 1080 ], story: [ 1080, 1920 ] }.freeze
  KINDS = %i[report brand calendar].freeze
  FONT = OgImage::FONT_FAMILY
  TOP = [ 30, 41, 59 ].freeze       # slate-800
  BOTTOM = [ 15, 23, 42 ].freeze    # slate-900
  CYAN = OgImage::CYAN
  AMBER = [ 251, 191, 36 ].freeze   # amber-400
  WHITE = OgImage::WHITE
  MUTED = OgImage::MUTED
  PAD = 90

  def initialize(kind, format: :post, data: nil)
    @kind = KINDS.include?(kind.to_sym) ? kind.to_sym : :brand
    @w, @h = FORMATS.fetch(format.to_sym, FORMATS[:post])
    @data = data
  end

  def to_png
    @img = background
    send("draw_#{@kind}")
    @img.write_to_buffer(".png", compression: 9)
  end

  private

  def draw_brand
    mid = @h / 2
    text("CHASE THE POWDER", mid - 190, size: 44, weight: "ExtraBold", color: AMBER, align: :center, spacing: 6)
    logo(mid - 90, size: 150)
    text("Find the most snow.\nBook the trip. Send it.", mid + 110, size: 52, weight: "Medium", color: MUTED, align: :center)
    footer("7-day snow forecasts for 200+ ski resorts")
  end

  def draw_calendar
    mid = @h / 2
    text("FREE DOWNLOAD", mid - 330, size: 40, weight: "ExtraBold", color: AMBER, align: :center, spacing: 6)
    text("The Powder\nCalendar", mid - 250, size: 120, weight: "ExtraBold", color: WHITE, align: :center)
    text("The best month for powder\nat every major ski resort,\non one page.", mid + 40, size: 50, weight: "Medium", color: MUTED, align: :center)
    text("snowway.app/powder-calendar", mid + 300, size: 44, weight: "Bold", color: CYAN, align: :center)
    logo(@h - PAD - 70, size: 56)
  end

  def draw_report
    data = @data || PowderReport.build_data
    from, to = data["window"].map { |d| Date.parse(d) }
    rows = data["top"].first(5)
    top_y = @h > 1400 ? 360 : 110

    logo(top_y, size: 54)
    text("WHERE IT'S DUMPING", top_y + 110, size: 38, weight: "ExtraBold", color: AMBER, align: :center, spacing: 6)
    text("Snowiest resorts\nthis week", top_y + 170, size: 92, weight: "ExtraBold", color: WHITE, align: :center)
    text("#{from.strftime("%b %-d")}–#{to.strftime(from.month == to.month ? "%-d" : "%b %-d")} · 7-day forecast", top_y + 400, size: 38, weight: "SemiBold", color: MUTED, align: :center)

    max = rows.map { |r| r["inches"].to_f }.max.to_f
    row_h = 122
    y = top_y + 480
    if max <= 0
      text("A quiet week.\nNo big storms in the forecast yet.", y + 100, size: 52, weight: "SemiBold", color: WHITE, align: :center)
    else
      rows.each_with_index do |r, i|
        bar_w = ((@w - 2 * PAD) * (r["inches"].to_f / max)).round.clamp(8, @w - 2 * PAD)
        @img = @img.draw_rect(CYAN.each_with_index.map { |c, j| (c * 0.18 + BOTTOM[j] * 0.82).round }, PAD, y, bar_w, row_h - 18, fill: true)
        text("#{i + 1}", y + 26, size: 50, weight: "ExtraBold", color: CYAN, x: PAD + 28)
        text(fit(r["name"], 44, "Bold", @w - 2 * PAD - 330), y + 12, size: 44, weight: "Bold", color: WHITE, x: PAD + 100)
        text(r["region"].to_s, y + 62, size: 30, weight: "Medium", color: MUTED, x: PAD + 100)
        text("#{r["inches"].round}\"", y + 22, size: 64, weight: "ExtraBold", color: CYAN, x: @w - PAD - 28, align: :right)
        y += row_h
      end
    end
    footer("Full list: snowway.app/powder-report")
  end

  # Shorten a single line with an ellipsis until it fits max_width.
  def fit(str, size, weight, max_width)
    return str if render(ERB::Util.h(str), size, weight).width <= max_width
    cut = str.dup
    cut = cut[0..-2].rstrip while cut.length > 4 && render(ERB::Util.h("#{cut}…"), size, weight).width > max_width
    "#{cut}…"
  end

  def background
    img = Vips::Image.black(@w, @h, bands: 3).copy(interpretation: :srgb)
    # vertical gradient TOP -> BOTTOM
    t = Vips::Image.xyz(@w, @h).extract_band(1).cast(:float) / (@h - 1)
    bands = 3.times.map { |i| t * (BOTTOM[i] - TOP[i]) + TOP[i] }
    img = bands[0].bandjoin(bands[1..]).cast(:uchar).copy(interpretation: :srgb)
    rng = Random.new(42)
    (@w * @h / 9000).times do
      x, y = rng.rand(@w), rng.rand(@h)
      shade = 90 + rng.rand(70)
      img = img.draw_circle([ shade, shade + 10, shade + 25 ], x, y, rng.rand(1..3), fill: true)
    end
    img
  end

  def logo(y, size:)
    snow = render("SNOW", size, "ExtraBold")
    way = render("WAY", size, "ExtraBold")
    x = (@w - snow.width - way.width) / 2
    paste(snow, x, y, WHITE)
    paste(way, x + snow.width, y, CYAN)
  end

  def footer(str)
    text(str, @h - PAD - 10, size: 34, weight: "SemiBold", color: MUTED, align: :center)
  end

  def text(str, y, size:, weight:, color:, align: :left, x: nil, width: nil, spacing: nil)
    markup = spacing ? %(<span letter_spacing="#{spacing * 1024}">#{ERB::Util.h(str)}</span>) : ERB::Util.h(str)
    t = render(markup, size, weight, width: width, align: align)
    x = case align
    when :center then (@w - t.width) / 2
    when :right then (x || @w - PAD) - t.width
    else x || PAD
    end
    paste(t, x, y, color)
  end

  def render(str, size, weight, width: nil, align: :left)
    opts = { font: "#{FONT} #{weight} #{size}", rgba: true, dpi: 72, align: (align == :center ? :centre : :low) }
    opts[:width] = width if width
    file = Rails.root.join("vendor/fonts/PlusJakartaSans-#{weight}.ttf")
    opts[:fontfile] = file.to_s if file.exist? # macOS Pango ignores fontconfig dirs; load the bundled font directly
    Vips::Image.text(str, **opts)
  end

  def paste(t, x, y, color)
    alpha = t.extract_band(3)
    colored = t.extract_band(0, n: 3).new_from_image(color).copy(interpretation: :srgb).bandjoin(alpha)
    @img = @img.composite2(colored, :over, x: x, y: y).flatten
  end
end
