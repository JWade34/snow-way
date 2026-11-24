class ChristmasTownsController < ApplicationController
  def show
    @town = ChristmasTown.find(params[:town])
    @totals = Resort.projected_totals
    @dec = SkiMonth.find("december")
  end
end
