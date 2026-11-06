require "test_helper"

class ResortTest < ActiveSupport::TestCase
  test "data file entries are valid and have unique slugs" do
    rows = YAML.load_file(Resort::DATA_FILE)
    assert_equal rows.size, rows.map { |r| r["slug"] }.uniq.size
    rows.each do |attrs|
      errors = Resort.new(attrs).tap(&:valid?).errors.reject { |e| e.attribute == :slug && e.type == :taken }
      assert_empty errors.map(&:full_message), "#{attrs["name"]} is invalid"
      assert attrs["elevation_summit"] > attrs["elevation_base"], "#{attrs["name"]} summit must exceed base"
      assert Resort::AIRPORTS.key?(attrs["nearest_airport_code"]), "#{attrs["name"]} airport #{attrs["nearest_airport_code"]} has no name"
    end
  end

  test "sync creates new resorts and updates existing ones" do
    created = Resort.sync_from_data_file!
    assert created.none? { |r| r.slug == "vail" }
    assert Resort.exists?(slug: "beaver-creek")
  end

  test "every guide belongs to at least one topic hub" do
    orphans = Guide.all.map(&:slug) - GuideTopic.all.flat_map(&:guide_slugs)
    assert_empty orphans, "add these guides to a topic in GuideTopic::TOPICS"
    assert_empty GuideTopic.all.flat_map(&:guide_slugs) - Guide.all.map(&:slug), "topic lists a guide that doesn't exist"
  end
end
