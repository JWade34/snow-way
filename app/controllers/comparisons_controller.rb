class ComparisonsController < ApplicationController
  def index
    @comparisons = Comparison.all
  end

  def show
    @comparison = Comparison.find(params[:id])
    @summaries = @comparison.resorts.map { |r| ResortSummary.new(r) }
    @totals_14 = Resort.projected_totals(days: 14)
  end
end
