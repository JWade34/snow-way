require "test_helper"

class SnowForecastTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "uses the model's snowfall when it forecasts snow" do
    daily = { "time" => [ "2026-11-27" ], "snowfall_sum" => [ 10.0 ] }
    hourly = { "time" => [ "2026-11-27T03:00" ], "temperature_2m" => [ -5.0 ], "precipitation" => [ 50.0 ] }
    assert_equal 3.9, SnowForecast.daily_snowfall(daily, hourly).first[:snowfall_inches]
  end

  test "rain hours never count as snow, even on a day that averages near freezing" do
    # Pats Peak, Nov 27 2026: 17mm of rain at +1 to +3°C. The old daily-mean fallback called this 5.5 inches.
    daily = { "time" => [ "2026-11-27" ], "snowfall_sum" => [ 0.0 ], "temperature_2m_mean" => [ 1.7 ] }
    hourly = { "time" => %w[2026-11-27T06:00 2026-11-27T07:00], "temperature_2m" => [ 1.2, 2.8 ], "precipitation" => [ 9.0, 8.4 ] }
    assert_equal 0.0, SnowForecast.daily_snowfall(daily, hourly).first[:snowfall_inches]
  end

  test "counts precipitation in freezing hours when the model's grid is too warm for snow" do
    daily = { "time" => [ "2026-11-27", "2026-11-28" ], "snowfall_sum" => [ 0.0, 0.0 ] }
    hourly = { "time" => %w[2026-11-27T22:00 2026-11-27T23:00 2026-11-28T00:00],
               "temperature_2m" => [ -1.0, 0.5, -2.0 ], "precipitation" => [ 10.0, 10.0, 5.0 ] }
    days = SnowForecast.daily_snowfall(daily, hourly)
    assert_equal 2.8, days[0][:snowfall_inches] # 10mm frozen x 0.7 = 7cm; the +0.5°C hour is rain
    assert_equal 1.4, days[1][:snowfall_inches]
  end
end
