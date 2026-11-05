class GuidesController < ApplicationController
  def index
    @guides = Guide.all
  end

  def show
    @guide = Guide.find(params[:id])
    @totals = Resort.projected_totals
    @top = Resort.where(id: @totals.sort_by { |_, v| -v }.first(5).map(&:first)).to_a.sort_by { |r| -@totals[r.id] }
  end
end
