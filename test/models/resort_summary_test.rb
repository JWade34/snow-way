require "test_helper"

class ResortSummaryTest < ActiveSupport::TestCase
  setup do
    @vail = ResortSummary.new(resorts(:vail).reload)
  end

  test "totals only the 7-day window" do
    assert_in_delta 6.5, @vail.total
    assert_in_delta 6.5, resorts(:vail).projected_snowfall_7_day
  end

  test "ranks against every resort with forecasts" do
    assert_equal 2, @vail.rank
    assert_equal 3, @vail.ranked_count
  end

  test "answer is dated and states total, rank, biggest day and recent snow" do
    answer = @vail.answer
    assert_includes answer, Date.current.strftime("%B %-d, %Y")
    assert_includes answer, "6.5\" of snow at mid-mountain over the next 7 days"
    assert_includes answer, "ranking #2 of 3"
    assert_includes answer, "with 6.0\""
    assert_includes answer, "2.0\" in the last 48 hours"
  end

  test "next snow day uses the 1 inch threshold" do
    assert_equal Date.current + 2, @vail.next_snow_day.forecast_date
  end

  test "no-snow resort says so plainly" do
    summary = ResortSummary.new(resorts(:alyeska))
    assert_includes summary.answer, "no new snow in the forecast"
    assert_includes summary.faqs.find { |f| f[:question].start_with?("When is snow") }[:answer], "No day with 1 inch or more"
  end

  test "14-day total includes days 8 to 14 and the FAQ flags low confidence" do
    assert_in_delta 36.5, @vail.total_14
    faq = @vail.faqs.find { |f| f[:question].start_with?("What is the 14-day") }
    assert_includes faq[:answer], "low-confidence"
  end

  test "faqs include state comparison only when peers exist" do
    assert @vail.faqs.any? { |f| f[:question].include?("other Colorado ski resorts") }
    assert_not ResortSummary.new(resorts(:alyeska)).faqs.any? { |f| f[:question].include?("compare") }
  end
end

class SizeChartTest < ActiveSupport::TestCase
  test "snowboard length for 5'9 all-mountain is chin to nose" do
    range = SizeChart.snowboard_length(height_cm: SizeChart.cm(5, 9))
    assert_equal 148..156, range
  end

  test "ski length scales with ability and terrain" do
    h = SizeChart.cm(5, 9)
    assert SizeChart.ski_length(height_cm: h, ability: "beginner").first < SizeChart.ski_length(height_cm: h, ability: "expert").first
    assert SizeChart.ski_length(height_cm: h, style: "powder").first > SizeChart.ski_length(height_cm: h).first
  end

  test "wide board from men's 11" do
    assert_equal "Wide (W)", SizeChart.board_width(11)
    assert_equal "Regular", SizeChart.board_width(9)
  end
end
