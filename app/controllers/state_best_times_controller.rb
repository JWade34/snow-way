class StateBestTimesController < ApplicationController
  def show
    @state = StateBestTime.find(params[:state])
  end
end
