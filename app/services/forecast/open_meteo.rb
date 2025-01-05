class Forecast::OpenMeteo < Forecast::Base
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
    case code
    when 1
      "Clear sky"
    when 2
      "Partly cloudy"
    when 3
      "Cloudy"
    when 4
      "Overcast"
    when 5
      "Showers"
    when 6
      "Rain"
    when 7
      "Snow"
    when 8
      "Thunderstorm"
    when 9
      "Other"
    else
      "Unknown weather"
    end
  end

  # Format the forecast into a readable message
  def format_forecast(temperature, windspeed, winddirection, weather_description)
    time_of_day = (Time.now.hour < 18) ? "day" : "night"

    # Format the wind direction to a cardinal direction (optional)
    wind_direction_cardinal = wind_direction_to_cardinal(winddirection)

    # Construct a readable message
    "Current temperature is #{temperature}°C, with #{weather_description}. The wind is blowing at #{windspeed} km/h from the #{wind_direction_cardinal}."
  end

  # Convert wind direction (in degrees) to a cardinal direction
  def wind_direction_to_cardinal(degrees)
    case degrees
    when 0..22
      "North"
    when 23..67
      "North-East"
    when 68..112
      "East"
    when 113..157
      "South-East"
    when 158..202
      "South"
    when 203..247
      "South-West"
    when 248..292
      "West"
    when 293..337
      "North-West"
    else
      "Unknown"
    end
  end

  def base_url
    'https://api.open-meteo.com/v1/forecast'
  end
end
