require "test_helper"

class BlackFridayAndCaptureTest < ActionDispatch::IntegrationTest
  test "deal box sits under the short answer during the window" do
    travel_to Date.new(2026, 11, 25) do
      get guide_path("best-snowboard-brands")
      assert_response :success
      assert_select "aside[data-placement=black_friday] a[rel~=sponsored]", minimum: 3
      assert response.body.index('class="tldr"') < response.body.index("black-friday-heading"), "short answer must stay first"
    end
  end

  test "deal box is gone after Cyber Monday" do
    travel_to Date.new(2026, 12, 2) do
      get guide_path("best-snowboard-brands")
      assert_select "aside[data-placement=black_friday]", 0
    end
  end

  test "gear guides get the checklist email field, how-to guides get the calendar field" do
    get guide_path("best-ski-goggles")
    assert_select "aside[data-placement=checklist_cta] input[type=email]", 1
    get guide_path("how-to-ski")
    assert_select "aside[data-placement=calendar_cta] input[type=email]", 1
  end

  test "ski size chart has an email field" do
    get ski_size_chart_path
    assert_select "#powder-calendar-form input[type=email]", 1
  end

  test "gift guides and christmas page render with affiliate and lodging links" do
    %w[gifts-for-skiers gifts-for-snowboarders].each do |slug|
      get guide_path(slug)
      assert_response :success
      assert_select "a[rel~=sponsored]", minimum: 10
    end
    get christmas_skiing_path
    assert_response :success
    assert_select "section[data-placement=christmas_week] a[href*='checkin=']", minimum: 1
    assert_select "script[type='application/ld+json']", minimum: 1
  end

  test "pass deal answers expire with the offers" do
    travel_to(Date.new(2026, 11, 25)) { assert_equal 3, PassDeals.faqs.size }
    travel_to(Date.new(2026, 12, 1)) { assert_equal 2, PassDeals.faqs.size }
    travel_to(Date.new(2026, 12, 7)) { assert_empty PassDeals.faqs }
  end

  test "open-now page renders and delayed resorts never read as scheduled" do
    get open_now_path
    assert_response :success
    assert_select "h1", /open now/i
    r = Resort.first
    r.update!(opening_status: "delayed", opening_date: Date.current - 3)
    assert_equal "Delayed (no new date)", r.opening_label
    assert_equal "Delayed", r.season_status[:label]
    r.update!(opening_date: Date.current + 3)
    assert_match(/\ADelayed to /, r.opening_label)
  end
end
