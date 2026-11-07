# Rule-of-thumb ski and snowboard sizing, shared by the size chart pages and their tests.
# The calculator in app/javascript/controllers/size_calculator_controller.js mirrors these numbers.
module SizeChart
  SKI_ABILITY = { "beginner" => -15, "intermediate" => -8, "advanced" => -2, "expert" => 4 }.freeze
  SKI_STYLE = { "groomers" => -3, "all-mountain" => 0, "powder" => 5, "park" => -5 }.freeze
  BOARD_STYLE = { "park" => -4, "all-mountain" => 0, "powder" => 4 }.freeze
  BOARD_ABILITY = { "beginner" => -2, "intermediate" => 0, "advanced" => 1 }.freeze

  module_function

  def cm(feet, inches = 0)
    ((feet * 12 + inches) * 2.54).round
  end

  # +/- 3 cm when weight is high or low for height (BMI outside about 19-27).
  def weight_adjust(height_cm, weight_lb)
    return 0 unless weight_lb && height_cm.positive?

    bmi = (weight_lb * 0.4536) / ((height_cm / 100.0)**2)
    return 3 if bmi > 27
    return -3 if bmi < 19
    0
  end

  def ski_length(height_cm:, weight_lb: nil, ability: "intermediate", style: "all-mountain")
    center = height_cm + SKI_ABILITY.fetch(ability) + SKI_STYLE.fetch(style) + weight_adjust(height_cm, weight_lb)
    (center - 3)..(center + 3)
  end

  def snowboard_length(height_cm:, weight_lb: nil, ability: "intermediate", style: "all-mountain")
    center = (height_cm * 0.87).round + BOARD_STYLE.fetch(style) + BOARD_ABILITY.fetch(ability) + weight_adjust(height_cm, weight_lb)
    (center - 4)..(center + 4)
  end

  # Ski poles: about 0.68 x height, rounded to the nearest 5 cm.
  def pole_length(height_cm)
    ((height_cm * 0.68) / 5.0).round * 5
  end

  # Men's US boot size; women's sizes are about 1.5 larger than men's for the same foot.
  def board_width(mens_boot_size)
    return "Wide (W)" if mens_boot_size >= 11
    return "Regular or mid-wide" if mens_boot_size >= 10
    "Regular"
  end

  # Ski boots: mondopoint is foot length in cm. US men's = mondo - 18, US women's = mondo - 17 (common conversion).
  # The boot calculator in app/javascript/controllers/boot_size_controller.js mirrors these numbers.
  def mondo_rows
    (22.0..31.0).step(0.5).map do |mondo|
      { mondo: mondo, mens: mondo - 18, womens: mondo - 17, eu: ((mondo * 1.5 + 2) * 2).round / 2.0 }
    end
  end

  def mondo_from_us(size, womens: false)
    size + (womens ? 17 : 18)
  end

  # Typical flex ranges by ability; brands rate flex differently, so treat these as starting points.
  BOOT_FLEX = [
    [ "Beginner", "60–80", "50–70" ],
    [ "Intermediate", "80–100", "70–90" ],
    [ "Advanced", "100–120", "90–110" ],
    [ "Expert", "120–140", "110–130" ]
  ].freeze

  BOOT_LAST = [
    [ "Narrow", "97–98 mm", "Low-volume, narrow feet and heels" ],
    [ "Medium", "99–101 mm", "Most feet; the most common last" ],
    [ "Wide", "102–106 mm", "Wide forefoot or high instep" ]
  ].freeze

  def heights
    (58..78).step(2).map { |inches| [ inches / 12, inches % 12 ] }
  end
end
