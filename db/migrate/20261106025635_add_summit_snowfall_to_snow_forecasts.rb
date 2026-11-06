class AddSummitSnowfallToSnowForecasts < ActiveRecord::Migration[8.1]
  def change
    add_column :snow_forecasts, :snowfall_summit_inches, :decimal
  end
end
