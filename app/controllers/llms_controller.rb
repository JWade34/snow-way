# /llms.txt and /llms-full.txt: plain-text indexes for AI assistants and answer engines.
class LlmsController < ApplicationController
  def index
    @resorts = Resort.order(:name).to_a.sort_by { |r| [ r.north_american? ? 0 : 1, r.region_name, r.name ] }
    @totals = Resort.projected_totals
    render formats: :text, content_type: "text/plain"
  end

  def full
    @totals = Resort.projected_totals
    totals_14 = Resort.projected_totals(days: 14)
    @summaries = Resort.includes(:snow_forecasts).to_a
      .sort_by { |r| [ r.north_american? ? 0 : 1, -@totals.fetch(r.id, 0.0) ] }
      .map { |r| ResortSummary.new(r, totals: @totals, totals_14: totals_14) }
    # Guides: description plus the FAQ each guide partial collects while rendering.
    @guides = Rails.cache.fetch([ "llms-guides", Guide.all.size, Rails.application.config.assets.version ], expires_in: 1.day) do
      Guide.all.map do |g|
        faqs = []
        render_to_string(partial: g.partial, formats: [ :html ], locals: { faqs: faqs })
        { slug: g.slug, title: g.title, description: g.description, faqs: faqs.map { |f| { question: f[:question] || f["question"], answer: f[:answer] || f["answer"] } } }
      end
    end
    render formats: :text, content_type: "text/plain"
  end
end
