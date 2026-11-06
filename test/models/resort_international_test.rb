require "test_helper"

class ResortInternationalTest < ActiveSupport::TestCase
  setup { Resort.sync_from_data_file! }

  test "international resorts group by country and rank separately" do
    niseko = Resort.find_by!(slug: "niseko-united")
    vail = Resort.find_by!(slug: "vail")
    assert_equal "Japan", niseko.region_name
    assert_equal "japan", niseko.region_slug
    assert_equal "Colorado", vail.region_name
    assert_not_includes Resort.north_america, niseko
    assert_includes niseko.ranking_pool, Resort.find_by!(slug: "chamonix")
    assert_not_includes niseko.ranking_pool, vail
  end

  test "snowiest months stay inside each hemisphere's ski season" do
    portillo = Resort.find_by!(slug: "portillo")
    assert portillo.southern_hemisphere?
    assert portillo.snowiest_months.all? { |m, _| (6..10).cover?(m) }
    assert Resort.find_by!(slug: "st-moritz").snowiest_months.none? { |m, _| (6..10).cover?(m) }
  end

  test "region directories exist for countries and international groups" do
    slugs = (Region.all + Region.groups).map(&:slug)
    assert_includes slugs, "japan"
    assert_includes slugs, "the-alps"
    assert_includes slugs, "southern-hemisphere"
    assert_not_includes slugs, "hokkaido"
  end
end
