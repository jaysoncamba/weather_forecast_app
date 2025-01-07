# Weather Forecast App

A simple web application that allows users to search for locations and view current weather forecasts using the OpenMeteo API. The app provides location suggestions as users type, and shows detailed weather information such as temperature, wind speed, and weather description for the selected location.

## Features

- **Location Search**: Type a location to receive search suggestions.
- **Weather Forecast**: View current weather for the selected location, including temperature, wind speed, and weather description.
- **Error Handling**: Displays error messages if the location is invalid or missing latitude/longitude.
- **Responsive Design**: Works well on both desktop and mobile devices.

## Tech Stack

- **Backend**: Ruby on Rails 7
- **Frontend**: HTML, CSS, Bootstrap 5, JavaScript (Stimulus.js)
- **Weather API**: OpenMeteo API for weather data
- **Geocoding**: Geocoder gem for location search suggestions

## Setup

Follow these steps to get the application up and running on your local machine:

### 1. Clone the Repository
Clone this repository to your local machine.

```bash
git clone https://github.com/jaysoncamba/weather_forecast_app.git
cd weather-forecast-app
```

### 2. Install Dependencies
Run the following command to install the required gems.

```bash
bundle install
```

### 3. Set Up the Database
Set up the database by running the following commands:

```bash
rails db:create
rails db:migrate
```

### 4. Start the Rails Server
Start the Rails server to run the application locally.

```bash
rails server
```
Visit http://localhost:3000 in your browser.

## Usage

### Searching Locations
- On the homepage, enter a location name into the search bar.
- Suggestions will appear below the search box as you type.
- Select a suggestion to automatically populate the search field.
- Click the **Search** button to view the weather forecast for the selected location.

### Viewing Weather Forecast
- After searching, the app will display the current weather for the selected location, including:
  - Temperature (°C)
  - Wind Speed (km/h)
  - Weather Description (e.g., Clear sky, Rain, Snow)
  - Wind Direction

## API Integration

### OpenMeteo API
The application uses the [OpenMeteo API](https://open-meteo.com/) to retrieve weather data. The app fetches current weather data based on the latitude and longitude of the selected location. You can adjust the API endpoint and parameters in the service class `Forecast::OpenMeteo` if necessary.

### Geocoding
The app uses the [Geocoder gem](https://github.com/alexreisner/geocoder) to fetch location suggestions based on user input.

## Testing

To run the tests, use the following command:

```bash
rails test
```