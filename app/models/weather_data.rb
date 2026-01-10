require "net/http"
require "json"

class WeatherData
  include ActiveModel::Model

  attr_accessor :resort, :temperature_f, :wind_speed_mph, :snow_depth_inches,
                :weather_code, :is_day, :fetched_at

  WEATHER_CODES = {
    0 => { icon: "☀️", description: "Clear sky" },
    1 => { icon: "🌤️", description: "Mainly clear" },
    2 => { icon: "⛅", description: "Partly cloudy" },
    3 => { icon: "☁️", description: "Overcast" },
    45 => { icon: "🌫️", description: "Foggy" },
    48 => { icon: "🌫️", description: "Depositing rime fog" },
    51 => { icon: "🌧️", description: "Light drizzle" },
    53 => { icon: "🌧️", description: "Moderate drizzle" },
    55 => { icon: "🌧️", description: "Dense drizzle" },
    61 => { icon: "🌧️", description: "Slight rain" },
    63 => { icon: "🌧️", description: "Moderate rain" },
    65 => { icon: "🌧️", description: "Heavy rain" },
    66 => { icon: "🌨️", description: "Light freezing rain" },
    67 => { icon: "🌨️", description: "Heavy freezing rain" },
    71 => { icon: "🌨️", description: "Slight snow" },
    73 => { icon: "❄️", description: "Moderate snow" },
    75 => { icon: "❄️", description: "Heavy snow" },
    77 => { icon: "❄️", description: "Snow grains" },
    80 => { icon: "🌧️", description: "Slight rain showers" },
    81 => { icon: "🌧️", description: "Moderate rain showers" },
    82 => { icon: "🌧️", description: "Violent rain showers" },
    85 => { icon: "🌨️", description: "Slight snow showers" },
    86 => { icon: "❄️", description: "Heavy snow showers" },
    95 => { icon: "⛈️", description: "Thunderstorm" },
    96 => { icon: "⛈️", description: "Thunderstorm with slight hail" },
    99 => { icon: "⛈️", description: "Thunderstorm with heavy hail" }
  }.freeze

  def self.fetch_for_resort(resort)
    return nil unless resort

    response = fetch_from_api(resort.latitude, resort.longitude)
    return nil unless response

    current = response["current"]
    new(
      resort: resort,
      temperature_f: celsius_to_fahrenheit(current["temperature_2m"]),
      wind_speed_mph: kmh_to_mph(current["wind_speed_10m"]),
      snow_depth_inches: meters_to_inches(current["snow_depth"]),
      weather_code: current["weather_code"],
      is_day: current["is_day"] == 1,
      fetched_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error "Weather fetch failed for #{resort.name}: #{e.message}"
    nil
  end

  def self.fetch_for_resorts(resorts)
    resorts.filter_map { |resort| fetch_for_resort(resort) }
  end

  def weather_icon
    WEATHER_CODES.dig(weather_code, :icon) || "🌡️"
  end

  def weather_description
    WEATHER_CODES.dig(weather_code, :description) || "Unknown"
  end

  def snowing?
    [ 71, 73, 75, 77, 85, 86 ].include?(weather_code)
  end

  def cold?
    temperature_f && temperature_f < 32
  end

  private

  def self.fetch_from_api(latitude, longitude)
    uri = URI("https://api.open-meteo.com/v1/forecast")
    uri.query = URI.encode_www_form(
      latitude: latitude,
      longitude: longitude,
      current: "temperature_2m,wind_speed_10m,snow_depth,weather_code,is_day",
      temperature_unit: "celsius",
      wind_speed_unit: "kmh",
      timezone: "auto"
    )

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def self.celsius_to_fahrenheit(celsius)
    return nil unless celsius
    ((celsius * 9.0 / 5.0) + 32).round(1)
  end

  def self.kmh_to_mph(kmh)
    return nil unless kmh
    (kmh * 0.621371).round(1)
  end

  def self.meters_to_inches(meters)
    return nil unless meters
    (meters * 39.3701).round(1)
  end
end
