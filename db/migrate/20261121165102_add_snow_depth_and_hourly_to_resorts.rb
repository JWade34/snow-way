class AddSnowDepthAndHourlyToResorts < ActiveRecord::Migration[8.1]
  def change
    add_column :resorts, :snow_depth_in, :integer
    add_column :resorts, :snow_depth_on, :date
    add_column :resorts, :hourly_forecast, :json
  end
end
