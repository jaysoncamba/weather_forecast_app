class LocationForecast < ApplicationRecord
  def forecast_data_with_location
    forecast.merge(location_name:)
  end
end
