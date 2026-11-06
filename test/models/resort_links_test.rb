require "test_helper"

class ResortLinksTest < ActiveSupport::TestCase
  test "every linked slug is a real resort and every link is https" do
    slugs = YAML.load_file(Rails.root.join("db/resorts.yml")).map { |r| r["slug"] }
    ResortLinks.data.each do |slug, links|
      assert_includes slugs, slug
      links.each_value { |url| assert_match %r{\Ahttps?://}, url, slug }
    end
  end
end
