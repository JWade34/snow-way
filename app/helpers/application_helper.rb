module ApplicationHelper
  SITE_URL = "https://snowway.app".freeze

  def absolute_url(path)
    "#{SITE_URL}#{path}"
  end

  # Renders a JSON-LD script tag. to_json escapes <, >, & so data can't break out of the tag.
  def json_ld(data)
    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  def faq_schema(faqs)
    return if faqs.blank?

    {
      "@type" => "FAQPage",
      "mainEntity" => faqs.map do |faq|
        { "@type" => "Question", "name" => faq[:question], "acceptedAnswer" => { "@type" => "Answer", "text" => faq[:answer] } }
      end
    }
  end

  # [["Ski Resorts", "/ski-resorts"], ["Colorado", nil]] — last item is the current page.
  def breadcrumb_schema(crumbs)
    {
      "@type" => "BreadcrumbList",
      "itemListElement" => ([ [ "Snow Way", "/" ] ] + crumbs).each_with_index.map do |(name, path), i|
        { "@type" => "ListItem", "position" => i + 1, "name" => name, "item" => (absolute_url(path) if path) }.compact
      end
    }
  end

  # First candidate that fits Google's ~70-character title display; the last one is used regardless.
  def fit_title(*candidates)
    candidates.find { |t| t.length <= 70 } || candidates.last
  end

  def squish_text(text)
    text.squish
  end

  def inches(value)
    "#{value.to_f.round(1)}\""
  end

  def updated_label(time)
    return unless time
    tag.time(time.in_time_zone("America/Denver").strftime("%b %-d, %Y at %-l:%M %p MT"), datetime: time.iso8601)
  end
end
