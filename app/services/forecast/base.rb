class Forecast::Base

  attr_reader :params, :forecast_data

  HEADERS = {
    "Content-Type" => "application/json"
  }

  def initialize(endpoint:, params: {})
    @endpoint = endpoint
    @params = params.freeze
    @forecast_data = nil 
  end

  def fetch_data
    return @forecast_data if forecast_data
    url = "#{base_url}#{@endpoint}"
    Rails.logger.debug("Fetching data from #{url} with params #{@params}")
    response = HTTParty.get(url, query: @params)
    
    Rails.logger.debug("Response: #{response.body}")
    @forecast_data = parse_response(response)
  end

  def parse_response(response)
    if response.success?
      response.parsed_response
    else
      raise StandardError, "Error fetching data from API: #{response.message}"
    end
  end

  def base_url
    raise NotImplementedError
  end
end
