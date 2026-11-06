class WeatherController < ApplicationController
  def index
    @resorts = Resort.north_america.by_most_snow.limit(10)
    @weather_data = WeatherData.fetch_for_resorts(@resorts)
  end
end
