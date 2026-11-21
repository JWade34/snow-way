require "net/http"
require "json"

module SnowForecastable
  extend ActiveSupport::Concern

  class_methods do
    # One request returns two points: mid-mountain (the headline number) and the summit.
    def fetch_forecasts_from_api(resort)
      return [] unless resort

      mid_meters = (resort.mid_elevation.to_f * 0.3048).round
      summit_meters = (resort.elevation_summit.to_f * 0.3048).round

      uri = URI("https://api.open-meteo.com/v1/forecast")
      uri.query = URI.encode_www_form(
        latitude: [ resort.latitude, resort.latitude ].join(","),
        longitude: [ resort.longitude, resort.longitude ].join(","),
        elevation: [ mid_meters, summit_meters ].join(","),
        daily: "precipitation_sum,temperature_2m_mean,snowfall_sum,temperature_2m_max,temperature_2m_min,weather_code,wind_speed_10m_max",
        hourly: "temperature_2m,precipitation,snowfall,weather_code,wind_speed_10m",
        current: "temperature_2m,wind_speed_10m,weather_code",
        timezone: "auto",
        forecast_days: 16,
        past_days: 2
      )

      response = Net::HTTP.get_response(uri)
      return [] unless response.is_a?(Net::HTTPSuccess)

      mid, summit = JSON.parse(response.body)
      return [] unless mid.is_a?(Hash) && summit.is_a?(Hash)

      store_current_conditions(resort, mid["current"])
      store_hourly(resort, mid["hourly"], mid["utc_offset_seconds"])
      mid_days = daily_snowfall(mid["daily"], mid["hourly"])
      summit_days = daily_snowfall(summit["daily"], summit["hourly"]).to_h { |d| [ d[:forecast_date], d[:snowfall_inches] ] }
      mid_days.map { |day| day.merge(snowfall_summit_inches: summit_days[day[:forecast_date]]) }
    rescue StandardError => e
      Rails.logger.error "Snow forecast fetch failed for #{resort&.name}: #{e.message}"
      []
    end

    # Snow per day at one elevation. The model's own snowfall is used whenever it forecasts snow. Its snowfall
    # ignores the elevation we ask for, though (it's computed for the model grid, often lower and warmer than
    # the slopes), so on days it says 0 we count precipitation from hours at or below freezing at this elevation,
    # at the model's own 7:1 snow-to-water ratio. Rain hours never count.
    def daily_snowfall(daily, hourly = nil)
      return [] unless daily && daily["time"]

      frozen_mm = freezing_precipitation_by_day(hourly)
      daily["time"].each_with_index.map do |date_str, i|
        snowfall_cm = daily["snowfall_sum"]&.dig(i).to_f
        snowfall_cm = frozen_mm.fetch(date_str, 0.0) * SNOW_CM_PER_MM if snowfall_cm <= 0
        snowfall_inches = (snowfall_cm * 0.393701).round(1)

        {
          forecast_date: Date.parse(date_str),
          snowfall_inches: snowfall_inches,
          temp_high_f: c_to_f(daily["temperature_2m_max"]&.dig(i)),
          temp_low_f: c_to_f(daily["temperature_2m_min"]&.dig(i)),
          weather_code: daily["weather_code"]&.dig(i),
          wind_max_mph: daily["wind_speed_10m_max"]&.dig(i)&.then { |kmh| (kmh * 0.621371).round }
        }
      end
    end

    def c_to_f(celsius)
      (celsius * 9.0 / 5 + 32).round if celsius
    end

    # Mid-mountain conditions at fetch time; skipped quietly if the API omits them.
    def store_current_conditions(resort, current)
      return unless current && resort.persisted?

      resort.update_columns(
        current_temp_f: c_to_f(current["temperature_2m"]),
        current_wind_mph: (current["wind_speed_10m"] * 0.621371).round,
        current_weather_code: current["weather_code"],
        conditions_at: Time.current
      )
    rescue StandardError => e
      Rails.logger.error "Storing conditions failed for #{resort.name}: #{e.message}"
    end

    SNOW_CM_PER_MM = 0.7 # Open-Meteo's snowfall conversion (7:1), kept the same so both paths agree

    # { "2026-11-27" => mm of precipitation that fell in hours at or below 0°C }
    def freezing_precipitation_by_day(hourly)
      return {} unless hourly && hourly["time"] && hourly["temperature_2m"] && hourly["precipitation"]

      hourly["time"].each_index.with_object(Hash.new(0.0)) do |i, days|
        temp = hourly["temperature_2m"][i]
        precip = hourly["precipitation"][i].to_f
        days[hourly["time"][i][0, 10]] += precip if temp && temp <= 0 && precip > 0
      end
    end

    HOURLY_HOURS = 72

    # The next 72 hours at mid-mountain for the "hour by hour" view. Snow per hour follows the same rule as the
    # daily totals: the model's snowfall, else precipitation in a freezing hour at 7:1, never rain.
    def store_hourly(resort, hourly, utc_offset)
      return unless hourly && hourly["time"] && resort.persisted?

      now_local = Time.now.utc + utc_offset.to_i
      start = now_local.strftime("%Y-%m-%dT%H:00")
      rows = hourly["time"].each_index.filter_map do |i|
        time = hourly["time"][i]
        next if time < start
        temp = hourly["temperature_2m"]&.dig(i)
        snow_cm = hourly["snowfall"]&.dig(i).to_f
        precip = hourly["precipitation"]&.dig(i).to_f
        snow_cm = precip * SNOW_CM_PER_MM if snow_cm <= 0 && temp && temp <= 0 && precip > 0
        { "t" => time, "temp_f" => c_to_f(temp), "snow_in" => (snow_cm * 0.393701).round(1),
          "rain" => snow_cm <= 0 && precip > 0, "code" => hourly["weather_code"]&.dig(i),
          "wind_mph" => hourly["wind_speed_10m"]&.dig(i)&.then { |kmh| (kmh * 0.621371).round } }
      end.first(HOURLY_HOURS)
      resort.update_columns(hourly_forecast: rows)
    rescue StandardError => e
      Rails.logger.error "Storing hourly forecast failed for #{resort.name}: #{e.message}"
    end

    def refresh_all_forecasts!
      Resort.find_each do |resort|
        refresh_forecasts_for!(resort)
        sleep 0.1 # Rate limiting
      end
    end

    def refresh_forecasts_for!(resort)
      forecasts = fetch_forecasts_from_api(resort)
      return if forecasts.empty?

      # Delete forecasts from 2 days ago through future (covers past + forecast window)
      resort.snow_forecasts.where(forecast_date: 2.days.ago.to_date..).delete_all

      # Insert all forecasts (past and future)
      forecasts.each do |forecast_data|
        resort.snow_forecasts.create!(forecast_data)
      end

      Rails.logger.info "Updated forecasts for #{resort.name}: #{forecasts.sum { |f| f[:snowfall_inches] }}\" total"
    end
  end
end
