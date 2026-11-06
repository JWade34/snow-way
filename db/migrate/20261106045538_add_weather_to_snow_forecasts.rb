class AddWeatherToSnowForecasts < ActiveRecord::Migration[8.1]
  def change
    add_column :snow_forecasts, :weather_code, :integer
    add_column :snow_forecasts, :wind_max_mph, :integer
  end
end
