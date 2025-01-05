class LocationsController < ApplicationController
  def search
    query = params[:q]
    results = Geocoder.search(query)
    suggestions = results.map { |result| result.data }.first(5)
    render json: suggestions
  end

  def forecast
    @location_forecast = LocationForecast.find_or_initialize_by(location_params)
    if @location_forecast.new_record?
      @location_forecast.update(forecast: Forecast::OpenMeteo.new(latitude: location_params[:latitude], longitude: location_params[:longitude]).fetch_forecast)
    end
    render json: { forecast_data: @location_forecast.forecast_data_with_location }
  end

  def location_params
    params.require(:location).permit(:latitude, :longitude, :location_name)
  end
end

