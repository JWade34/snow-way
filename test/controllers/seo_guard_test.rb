require "test_helper"

# Runs on every test run so no page can ship with broken SEO basics or dead internal links.
class SeoGuardTest < ActionDispatch::IntegrationTest
  setup do
    Resort.sync_from_data_file! # mirror production: all resorts, regions, and hubs
    PowderReport.snapshot!
    @pages = SitePages.all_paths.to_h do |path|
      get path
      assert_response :success, path
      [ path, Nokogiri::HTML(response.body) ]
    end
  end

  test "every page has a unique title of 70 characters or less and a description" do
    titles = {}
    @pages.each do |path, doc|
      title = doc.at("title")&.text.to_s.strip
      assert title.present?, "#{path}: missing title"
      assert title.length <= 70, "#{path}: title is #{title.length} chars: #{title}"
      assert_nil titles[title], "#{path}: duplicate title with #{titles[title]}"
      titles[title] = path

      description = doc.at('meta[name="description"]')&.[]("content").to_s
      assert description.length.between?(50, 160), "#{path}: description is #{description.length} chars"
    end
  end

  test "every page has a canonical URL, lang, and headings in order" do
    @pages.each do |path, doc|
      assert doc.at('link[rel="canonical"]'), "#{path}: no canonical"
      assert doc.at("html[lang]"), "#{path}: no lang"
      levels = doc.css("h1, h2, h3, h4").map { |h| h.name[1].to_i }
      levels.each_cons(2) { |a, b| assert b <= a + 1, "#{path}: heading jumps from h#{a} to h#{b}" }
    end
  end

  test "every image has alt text and every table header has text" do
    @pages.each do |path, doc|
      doc.css("img").each { |img| assert img["alt"], "#{path}: img without alt" }
      doc.css("th").each { |th| assert th.text.strip.present?, "#{path}: empty table header" }
    end
  end

  test "no internal link is broken" do
    links = @pages.values.flat_map { |doc| doc.css("a[href^='/']").map { |a| a["href"].split("#").first } }.uniq
    links.reject! { |href| href.start_with?("/powder-calendar/download/") || href.empty? }
    links.each do |href|
      get href
      assert_includes [ 200, 301, 302 ], response.status, "broken internal link: #{href}"
    end
  end
end
