class AddConditionsToResortsAndForecasts < ActiveRecord::Migration[8.1]
  def change
    add_column :resorts, :current_temp_f, :integer
    add_column :resorts, :current_wind_mph, :integer
    add_column :resorts, :current_weather_code, :integer
    add_column :resorts, :conditions_at, :datetime
    add_column :snow_forecasts, :temp_high_f, :integer
    add_column :snow_forecasts, :temp_low_f, :integer
  end
end
