class LocationsController < ApplicationController
  def search
    query = params[:q]
    results = Geocoder.search(query)
    suggestions = results.map { |result| result.address }.first(5)

    render json: suggestions
  end
end
