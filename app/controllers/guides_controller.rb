class GuidesController < ApplicationController
  def index
    @guides = Guide.all
  end

  def topic
    @topic = GuideTopic.find(params[:topic])
    @guides = @topic.guides
  end

  def show
    @guide = Guide.find(params[:id])
    @topic = GuideTopic.primary_for(@guide.slug)
    @totals = Resort.projected_totals
    @top = Resort.where(id: @totals.sort_by { |_, v| -v }.first(5).map(&:first)).to_a.sort_by { |r| -@totals[r.id] }
  end
end
