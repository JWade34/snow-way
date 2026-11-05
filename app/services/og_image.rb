require "vips"

# 1200x630 social share card for a resort: name, 7-day snow total, rank.
# Uses the bundled Plus Jakarta Sans (installed by the Dockerfile), falling back to DejaVu Sans.
class OgImage
  WIDTH = 1200
  HEIGHT = 630
  # In production the Dockerfile installs vendor/fonts system-wide; elsewhere a system sans-serif is used.
  FONT_FAMILY = "Plus Jakarta Sans, DejaVu Sans, sans-serif".freeze
  BG = [ 15, 23, 42 ].freeze        # slate-900
  CYAN = [ 34, 211, 238 ].freeze    # cyan-400
  WHITE = [ 255, 255, 255 ].freeze
  MUTED = [ 148, 163, 184 ].freeze  # slate-400

  def initialize(summary)
    @summary = summary
    @resort = summary.resort
  end

  def to_png
    image = Vips::Image.black(WIDTH, HEIGHT, bands: 3).new_from_image(BG).copy(interpretation: :srgb)
    image = draw(image, "SNOW", 72, 56, size: 40, weight: "ExtraBold", color: WHITE)
    image = draw(image, "WAY", 72 + text_width("SNOW", 40, "ExtraBold"), 56, size: 40, weight: "ExtraBold", color: CYAN)
    image = draw(image, "#{@resort.name} snow forecast", 72, 170, size: 60, weight: "Bold", color: WHITE, width: WIDTH - 144)
    image = draw(image, @resort.location, 72, 262, size: 32, weight: "Medium", color: MUTED)
    image = draw(image, "#{@summary.total}\"", 72, 330, size: 150, weight: "ExtraBold", color: CYAN)
    image = draw(image, "of snow in the next 7 days", 72, 520, size: 34, weight: "SemiBold", color: WHITE)
    if @summary.total > 0
      image = draw(image, "##{@summary.rank} of #{@summary.ranked_count} resorts", WIDTH - 72, 56, size: 34, weight: "Bold", color: MUTED, align: :right)
    end
    image = draw(image, "snowway.app", WIDTH - 72, 560, size: 28, weight: "SemiBold", color: MUTED, align: :right)
    image.write_to_buffer(".png", compression: 9)
  end

  private

  def text_image(str, size, weight, width: nil)
    opts = { font: "#{FONT_FAMILY} #{weight} #{size}", rgba: true, dpi: 72 }
    opts[:width] = width if width
    Vips::Image.text(str, **opts)
  end

  def text_width(str, size, weight)
    text_image(str, size, weight).width
  end

  def draw(image, str, x, y, size:, weight:, color:, width: nil, align: :left)
    text = text_image(str, size, weight, width: width)
    # Recolor the rendered glyphs, keeping their alpha for anti-aliasing.
    alpha = text.extract_band(3)
    colored = text.extract_band(0, n: 3).new_from_image(color).copy(interpretation: :srgb).bandjoin(alpha)
    x -= text.width if align == :right
    image.composite2(colored, :over, x: x, y: y).flatten
  end
end
