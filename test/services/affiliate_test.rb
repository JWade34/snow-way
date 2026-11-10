require "test_helper"

class AffiliateTest < ActiveSupport::TestCase
  def with_env(vars)
    old = vars.keys.to_h { |k| [ k, ENV[k] ] }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    old.each { |k, v| ENV[k] = v }
  end

  test "plain REI search links before any program is approved" do
    with_env("REI_IMPACT_LINK" => nil, "AMAZON_ASSOCIATE_TAG" => nil, "AVANTLINK_WEBSITE_ID" => nil) do
      assert_equal "https://www.rei.com/search?q=ski+gloves", Affiliate.gear_url("ski gloves")
    end
  end

  test "REI deep-links through the Impact tracking link" do
    with_env("REI_IMPACT_LINK" => "https://rei.example.net/c/1/2/3", "AMAZON_ASSOCIATE_TAG" => nil) do
      assert_equal "https://rei.example.net/c/1/2/3?u=https%3A%2F%2Fwww.rei.com%2Fsearch%3Fq%3Dski%2Bgloves", Affiliate.gear_url("ski gloves")
    end
  end

  test "Amazon only: every gear link uses the Amazon tag" do
    with_env("REI_IMPACT_LINK" => nil, "AVANTLINK_WEBSITE_ID" => nil, "AMAZON_ASSOCIATE_TAG" => "snowway-20") do
      assert_equal "https://www.amazon.com/s?k=ski+boots&tag=snowway-20", Affiliate.gear_url("ski boots")
    end
  end

  test "both approved: accessories to Amazon, core gear to REI" do
    with_env("REI_IMPACT_LINK" => "https://rei.example.net/c/1/2/3", "AMAZON_ASSOCIATE_TAG" => "snowway-20") do
      assert_match "amazon.com", Affiliate.gear_url("hand warmers")
      assert_match "rei.example.net", Affiliate.gear_url("all mountain skis")
    end
  end

  test "every guide with shopping links shows the affiliate disclosure" do
    Guide.all.each do |guide|
      body = Rails.root.join("app/views/guides/_#{guide.slug.tr("-", "_")}.html.erb")
      next unless body.exist? && body.read.match?(/gear_link|gear_url/)
      assert guide.affiliate?, "#{guide.slug} has gear links but no affiliate: true, so no disclosure shows"
    end
  end
end
