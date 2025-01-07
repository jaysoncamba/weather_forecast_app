class Forecast::OpenMeteo < Forecast::Base
  # Constants for weather codes and wind direction ranges
  WEATHER_CODES = {
    1 => "Clear sky",
    2 => "Partly cloudy",
    3 => "Cloudy",
    4 => "Overcast",
    5 => "Showers",
    6 => "Rain",
    7 => "Snow",
    8 => "Thunderstorm",
    9 => "Other"
  }.freeze

  WIND_DIRECTION_RANGES = {
    north: 0..22,
    north_east: 23..67,
    east: 68..112,
    south_east: 113..157,
    south: 158..202,
    south_west: 203..247,
    west: 248..292,
    north_west: 293..337
  }.freeze

  UNKNOWN_WIND_DIRECTION = "Unknown".freeze
  UNKNOWN_WEATHER = "Unknown weather".freeze
  BASE_URL = 'https://api.open-meteo.com/v1/forecast'.freeze

  def initialize(latitude:, longitude:)
    params = {
      latitude: latitude,
      longitude: longitude,
      current_weather: true
    }
    super(endpoint: '', params: params)
  end

  def fetch_forecast
    fetch_data
    return { error: "Unable to fetch forecast data" } if @forecast_data['current_weather'].nil?

    temperature = @forecast_data["current_weather"]["temperature"]
    wind_speed = @forecast_data["current_weather"]["windspeed"]
    wind_direction = @forecast_data["current_weather"]["winddirection"]
    weather_code = @forecast_data["current_weather"]["weathercode"]

    weather_description = map_weather_code(weather_code)
    forecast_message = format_forecast(temperature, wind_speed, wind_direction, weather_description)

    Rails.logger.debug("DATA: #{@forecast_data.inspect}")
    { temperature:, wind_speed:, wind_direction:, weather_description:, forecast_message: }
  end

  def map_weather_code(code)
    WEATHER_CODES[code] || UNKNOWN_WEATHER
  end

  def format_forecast(temperature, windspeed, winddirection, weather_description)
    time_of_day = (Time.now.hour < 18) ? "day" : "night"

    wind_direction_cardinal = wind_direction_to_cardinal(winddirection)

    "Current temperature is #{temperature}°C, with #{weather_description}. The wind is blowing at #{windspeed} km/h from the #{wind_direction_cardinal}."
  end

  def wind_direction_to_cardinal(degrees)
    WIND_DIRECTION_RANGES.each do |direction, range|
      return direction.to_s.split('_').map(&:capitalize).join(' ') if range.include?(degrees)
    end
    UNKNOWN_WIND_DIRECTION
  end

  def base_url
    BASE_URL
  end
end
