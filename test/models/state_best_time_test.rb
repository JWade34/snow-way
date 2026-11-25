require "test_helper"

class StateBestTimeTest < ActiveSupport::TestCase
  test "answers with the snowiest month from measured station data" do
    st = StateBestTime.new("Colorado", [ resorts(:vail) ])
    odds = PowderOdds.measured(resorts(:vail))
    best = StateBestTime::MONTHS.max_by { |m| [ odds[m], StateBestTime::MONTHS.index(m) ] }
    assert_equal best, st.best_month
    assert_includes st.answer, "The best time to ski in Colorado for powder is #{Date::MONTHNAMES[best]}"
    assert_includes st.answer, "#{odds[best]}% of #{Date::MONTHNAMES[best]} days"
    assert st.faqs.all? { |f| f[:answer].present? }
  end

  test "states need three measured resorts" do
    assert_empty StateBestTime.all # the test fixtures have one measured resort per state
  end
end
