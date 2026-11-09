class TravelListsController < ApplicationController
  before_action :load_common

  def winter_vacations = render_list("winter_vacations")
  def ski_towns = render_list("ski_towns")
  def beginner_resorts = render_list("beginner_resorts")
  def hot_springs = render_list("hot_springs")

  private

  def load_common
    @resorts = TravelList.resorts
    @totals = Resort.projected_totals
    @updated_at = SnowForecast.maximum(:created_at)
  end

  def render_list(key)
    @items = TravelList.list(key)
    raise ActiveRecord::RecordNotFound if @items.empty?
    render key
  end
end
