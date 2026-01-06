class Resort < ApplicationRecord
  has_many :snow_forecasts, dependent: :destroy

  validates :name, :slug, :latitude, :longitude, :nearest_airport_code, presence: true
  validates :slug, uniqueness: true

  # Get total projected snowfall for next 7 days
  def projected_snowfall_7_day
    snow_forecasts
      .where(forecast_date: Date.today..7.days.from_now)
      .sum(:snowfall_inches)
      .to_f
      .round(1)
  end

  # Scope to order by most snow projected
  scope :by_most_snow, -> {
    left_joins(:snow_forecasts)
      .where(snow_forecasts: { forecast_date: Date.today..7.days.from_now })
      .group(:id)
      .order(Arel.sql("COALESCE(SUM(snow_forecasts.snowfall_inches), 0) DESC"))
  }

  # Get top resort by projected snowfall
  def self.top_powder_destination
    by_most_snow.first
  end
end
