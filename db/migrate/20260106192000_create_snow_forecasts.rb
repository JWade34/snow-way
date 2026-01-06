class CreateSnowForecasts < ActiveRecord::Migration[8.0]
  def change
    create_table :snow_forecasts do |t|
      t.references :resort, null: false, foreign_key: true
      t.date :forecast_date
      t.decimal :snowfall_inches
      t.datetime :fetched_at

      t.timestamps
    end
  end
end
