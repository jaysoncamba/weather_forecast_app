require "test_helper"
require "minitest/mock"
require "ostruct"
require "webmock/minitest"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  def test_search
    query = "London"

    fake_results = [
      OpenStruct.new(data: { "latitude" => 51.5074, "longitude" => -0.1278, "location_name" => "London" })
    ]

    Geocoder.stub(:search, fake_results) do
      get locations_search_url, params: { q: query }

      assert_response :success
      suggestions = JSON.parse(response.body)
      assert_equal 1, suggestions.length
      assert_equal "London", suggestions.first["location_name"]
    end
  end

  def test_forecast_for_new_location
    location_params = { latitude: 51.5074, longitude: -0.1278, location_name: "London" }

    fake_forecast_data = {
      temperature: 15,
      wind_speed: 5,
      wind_direction: "East",
      weather_description: "Clear sky",
      forecast_message: "Current temperature is 15°C, with Clear sky. The wind is blowing at 5 km/h from the East."
    }

    forecast_mock = Minitest::Mock.new
    forecast_mock.expect(:fetch_forecast, fake_forecast_data)

    Forecast::OpenMeteo.stub(:new, forecast_mock) do
      post locations_forecast_url, params: { location: location_params }

      assert_response :success
      forecast_response = JSON.parse(response.body)
      assert_equal fake_forecast_data[:temperature], forecast_response["forecast_data"]["temperature"]
      assert_equal fake_forecast_data[:wind_speed], forecast_response["forecast_data"]["wind_speed"]
      assert_equal fake_forecast_data[:wind_direction], forecast_response["forecast_data"]["wind_direction"]
      assert_equal fake_forecast_data[:weather_description], forecast_response["forecast_data"]["weather_description"]
      assert_equal fake_forecast_data[:forecast_message], forecast_response["forecast_data"]["forecast_message"]
    end
  end

  def test_forecast_for_existing_location
    location_params = { latitude: 51.5074, longitude: -0.1278, location_name: "London" }

    LocationForecast.create!(
      location_name: "London",
      latitude: 51.5074,
      longitude: -0.1278,
      forecast: {
        temperature: 10,
        wind_speed: 3,
        wind_direction: "South",
        weather_description: "Cloudy",
        forecast_message: "Current temperature is 10°C, with Cloudy. The wind is blowing at 3 km/h from the South."
      }
    )

    post locations_forecast_url, params: { location: location_params }

    assert_response :success
    forecast_response = JSON.parse(response.body)
    assert_equal "London", forecast_response["forecast_data"]["location_name"]
    assert_equal 10, forecast_response["forecast_data"]["temperature"]
  end

  def test_invalid_forecast_request
    post locations_forecast_url, params: { location: { location_name: "Invalid Location" } }

    assert_response :unprocessable_entity
    assert_includes response.body, "Latitude and Longitude can't be blank"
  end
end
