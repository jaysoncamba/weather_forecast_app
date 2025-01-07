require "test_helper"
require "webmock/minitest"

class Forecast::BaseTest < ActiveSupport::TestCase
  class TestForecastService < Forecast::Base
    def base_url
      "https://api.weather.com"
    end
  end

  def setup
    @valid_params = { location: "London" }
    @invalid_params = { location: "InvalidLocation" }
    @endpoint = "/forecast"

    # Use the subclass with base_url implemented
    @forecast_service = TestForecastService.new(endpoint: @endpoint, params: @valid_params)
  end

  def test_fetch_data_successful_response
    stub_request(:get, "https://api.weather.com/forecast")
      .with(query: { location: "London" })
      .to_return(status: 200, body: '{"forecast": "sunny"}', headers: { "Content-Type" => "application/json" })

    forecast_data = @forecast_service.fetch_data

    assert_not_nil forecast_data
    assert_equal "sunny", forecast_data["forecast"]
  end

  def test_fetch_data_failure_response
    stub_request(:get, "https://api.weather.com/forecast")
      .with(query: { location: "InvalidLocation" })
      .to_return(status: 404, body: '{"error": "not found"}', headers: { "Content-Type" => "application/json" })

    assert_raises(StandardError, "Error fetching data from API: Not Found") do
      forecast_service = TestForecastService.new(endpoint: @endpoint, params: @invalid_params)
      forecast_service.fetch_data
    end
  end
end
