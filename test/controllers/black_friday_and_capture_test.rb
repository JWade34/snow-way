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
end
