require 'test_helper'
require 'webmock/minitest'

class Forecast::OpenMeteoTest < ActiveSupport::TestCase
  def setup
    # Setup for coordinates (latitude, longitude)
    @latitude = 51.5074 # Example: London latitude
    @longitude = -0.1278 # Example: London longitude
    @forecast_service = Forecast::OpenMeteo.new(latitude: @latitude, longitude: @longitude)
  end

  def test_fetch_forecast_successful_response
    stub_request(:get, Forecast::OpenMeteo::BASE_URL)
      .with(query: { latitude: @latitude, longitude: @longitude, current_weather: true })
      .to_return(
        status: 200,
        body: {
          "current_weather" => {
            "temperature" => 15,
            "windspeed" => 5,
            "winddirection" => 90,
            "weathercode" => 1
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    forecast = @forecast_service.fetch_forecast

    assert_equal 15, forecast[:temperature]
    assert_equal 5, forecast[:wind_speed]
    assert_equal 90, forecast[:wind_direction]
    assert_equal "Clear sky", forecast[:weather_description]
    assert_equal "Current temperature is 15°C, with Clear sky. The wind is blowing at 5 km/h from the East.", forecast[:forecast_message]
  end

  def test_fetch_forecast_missing_current_weather
    stub_request(:get, Forecast::OpenMeteo::BASE_URL)
      .with(query: { latitude: @latitude, longitude: @longitude, current_weather: true })
      .to_return(
        status: 200,
        body: {}.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    forecast = @forecast_service.fetch_forecast

    assert_equal({ error: "Unable to fetch forecast data" }, forecast)
  end

  def test_map_weather_code
    assert_equal "Clear sky", @forecast_service.map_weather_code(1)
    assert_equal "Partly cloudy", @forecast_service.map_weather_code(2)
    assert_equal "Cloudy", @forecast_service.map_weather_code(3)
    assert_equal "Overcast", @forecast_service.map_weather_code(4)
    assert_equal "Showers", @forecast_service.map_weather_code(5)
    assert_equal "Rain", @forecast_service.map_weather_code(6)
    assert_equal "Snow", @forecast_service.map_weather_code(7)
    assert_equal "Thunderstorm", @forecast_service.map_weather_code(8)
    assert_equal "Other", @forecast_service.map_weather_code(9)
    assert_equal "Unknown weather", @forecast_service.map_weather_code(99)
  end

  def test_wind_direction_to_cardinal
    assert_equal "North", @forecast_service.wind_direction_to_cardinal(0)
    assert_equal "North East", @forecast_service.wind_direction_to_cardinal(45)
    assert_equal "East", @forecast_service.wind_direction_to_cardinal(90)
    assert_equal "South East", @forecast_service.wind_direction_to_cardinal(135)
    assert_equal "South", @forecast_service.wind_direction_to_cardinal(180)
    assert_equal "South West", @forecast_service.wind_direction_to_cardinal(225)
    assert_equal "West", @forecast_service.wind_direction_to_cardinal(270)
    assert_equal "North West", @forecast_service.wind_direction_to_cardinal(315)
    assert_equal "Unknown", @forecast_service.wind_direction_to_cardinal(400) # Invalid value
  end

  def test_base_url
    assert_equal Forecast::OpenMeteo::BASE_URL, @forecast_service.base_url
  end
end
