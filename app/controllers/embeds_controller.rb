class EmbedsController < ApplicationController
  # The embed is meant to be framed on other sites.
  after_action :allow_framing, only: :powder_rankings

  def widget
  end

  def powder_rankings
    totals = Resort.projected_totals
    @limit = params.fetch(:limit, 5).to_i.clamp(3, 10)
    @resorts = Resort.where(id: totals.sort_by { |_, v| -v }.first(@limit).map(&:first)).to_a.sort_by { |r| -totals[r.id] }
    @totals = totals
    render layout: "embed"
  end

  private

  def allow_framing
    response.headers.delete("X-Frame-Options")
    response.headers["Content-Security-Policy"] = "frame-ancestors *"
  end
end
