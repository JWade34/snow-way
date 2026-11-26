require "test_helper"

class PassPriceHistoryTest < ActiveSupport::TestCase
  test "every step is dated and sourced, and prices only go up" do
    PassPriceHistory.all.each do |pass|
      assert pass.steps.all? { |s| s.sources.any? { |src| src["url"].start_with?("https://") && src["date"].present? } }, pass.name
      prices = pass.priced.map(&:adult)
      assert_equal prices.sort, prices, "#{pass.name} adult prices should never drop"
      assert_equal pass.steps.map(&:date).sort, pass.steps.map(&:date)
    end
  end

  test "rise is launch to latest adult price" do
    assert_equal({ dollars: 156, percent: 14 }, PassPriceHistory.find("epic").rise)
    assert_equal({ dollars: 130, percent: 9 }, PassPriceHistory.find("ikon").rise)
    assert_equal "2027-28", PassPriceHistory.next_season
  end

  test "epic goes off sale after December 6" do
    epic = PassPriceHistory.find("epic")
    assert_not epic.off_sale?(Date.new(2026, 12, 6))
    assert epic.off_sale?(Date.new(2026, 12, 7))
  end
end
