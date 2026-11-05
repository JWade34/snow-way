# /llms.txt and /llms-full.txt: plain-text indexes for AI assistants and answer engines.
class LlmsController < ApplicationController
  def index
    @resorts = Resort.order(:state_province, :name)
    @totals = Resort.projected_totals
    render formats: :text, content_type: "text/plain"
  end

  def full
    @totals = Resort.projected_totals
    totals_14 = Resort.projected_totals(days: 14)
    @summaries = Resort.includes(:snow_forecasts).to_a
      .sort_by { |r| -@totals.fetch(r.id, 0.0) }
      .map { |r| ResortSummary.new(r, totals: @totals, totals_14: totals_14) }
    render formats: :text, content_type: "text/plain"
  end
end
