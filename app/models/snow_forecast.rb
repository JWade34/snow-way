class SnowForecast < ApplicationRecord
  include SnowForecastable

  belongs_to :resort

  validates :forecast_date, presence: true
  validates :snowfall_inches, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
