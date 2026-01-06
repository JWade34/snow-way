class HomeController < ApplicationController
  def index
    @top_resort = Resort.top_powder_destination
    @top_resorts = Resort.by_most_snow.limit(5)
  end
end
