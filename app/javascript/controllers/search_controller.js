import { Controller } from "@hotwired/stimulus"
import { fetch } from "whatwg-fetch"

export default class extends Controller {
  static targets = ["input", "suggestions", "spinner", "forecastTable", "forecastMessage"]

  selectedTags = []

  connect() {
    // Clear previous state
    this.selectedTags = []
    this.inputTarget.addEventListener("keydown", (event) => {
      if (event.key === "Enter") {
        this.search(event)
      }
    })
  }

  async search(event) {
    const query = this.inputTarget.value

    if (query.length > 2 || event.type === 'click') {
      // Show loading spinner
      this.spinnerTarget.style.display = 'block'
      
      // Fetch suggestions from the backend
      const response = await fetch(`/locations/search?q=${query}`)
      const suggestions = await response.json()

      // Hide the loading spinner
      this.spinnerTarget.style.display = 'none'

      // Clear any existing suggestions
      this.suggestionsTarget.innerHTML = ""

      // Add new suggestions to the dropdown
      suggestions.forEach(suggestion => {
        const li = document.createElement("li")
        li.textContent = suggestion.display_name
        li.classList.add("list-group-item", "list-group-item-action", "cursor-pointer")
        
        // Event listener to populate input with selected suggestion
        li.addEventListener("click", () => {
          this.addTag(suggestion)
          this.removeSuggestion(suggestion)  // Remove the selected suggestion from the list
          this.closeSuggestions()
        })

        this.suggestionsTarget.appendChild(li)
        this.suggestionsTarget.style.display = "block"
      })
    } else {
      // Clear suggestions if query is too short
      this.suggestionsTarget.innerHTML = ""
    }
  }

  // Add a selected tag
  addTag(suggestion) {
    // Don't add duplicate tags
    if (!this.selectedTags.includes(suggestion)) {
      this.selectedTags.push(suggestion)
      this.updateSelectedTagsDisplay()
      // Fetch weather forecast after adding a tag
      this.fetchWeatherForecast(suggestion)
    }
  }

  // Remove a tag
  removeTag(suggestion) {
    this.selectedTags = this.selectedTags.filter(tag => tag !== suggestion)
    this.updateSelectedTagsDisplay()
  }

  // Update the display of selected tags
  updateSelectedTagsDisplay() {
    const selectedTagsContainer = document.getElementById("selected-tags")
    selectedTagsContainer.innerHTML = ""

    this.selectedTags.forEach(tag => {
      const badge = document.createElement("span")
      badge.classList.add("badge", "bg-primary", "me-2", "mb-2", "pe-4", "position-relative")

      // Tag text
      badge.textContent = tag.display_name

      // Remove button inside the badge
      const removeButton = document.createElement("button")
      removeButton.classList.add("btn-close", "btn-close-white", "position-absolute", "top-0", "end-0")
      removeButton.addEventListener("click", () => {
        this.removeTag(tag)
      })

      // Append remove button and badge to the selected tags container
      badge.appendChild(removeButton)
      selectedTagsContainer.appendChild(badge)
    })
  }

  // Remove the selected suggestion from the dropdown
  removeSuggestion(suggestion) {
    const suggestionItems = this.suggestionsTarget.querySelectorAll("li")
    suggestionItems.forEach(item => {
      if (item.textContent === suggestion.display_name) {
        item.remove()  // Remove the suggestion from the list
      }
    })
  }

  closeSuggestions() {
    this.suggestionsTarget.innerHTML = ""  // Clear the suggestions list
    this.suggestionsTarget.style.display = "none"  // Hide the suggestions dropdown
  }

  // Fetch and display weather forecast for the selected place
  async fetchWeatherForecast(suggestion) {
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
      const response = await fetch('/locations/forecast', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({
          location: { latitude: suggestion.lat, longitude: suggestion.lon, location_name: suggestion.display_name }
        })
      });
      const data = await response.json()
      // If successful, display the forecast data in the table
      if (data.forecast_data !== null || data.forecast_data !== undefined) {
        this.displayForecast(data.forecast_data)
      } else {
        this.displayForecastMessage('No forecast data available for this location.')
      }
    } catch (error) {
      console.error('Error fetching weather forecast:', error)
      this.displayForecastMessage('Error fetching weather forecast. Please try again later.')
    }
  }

  // Populate the weather forecast in the table
  displayForecast(forecastData) {
    const forecastTableBody = this.forecastTableTarget.querySelector("tbody")

      const row = document.createElement("tr")
      // Create cells for Location, Temperature, Weather, Wind Speed and Human interpreted forecast.
      row.innerHTML = `
        <td>${forecastData.location_name}</td>
        <td>${forecastData.temperature}°C</td>
        <td>${forecastData.weather_description}</td>
        <td>${forecastData.wind_speed} km/h</td>
        <td>${forecastData.forecast_message}</td>
      `

      forecastTableBody.appendChild(row)
  }

  // Display any messages in the forecast message container
  displayForecastMessage(message) {
    const forecastMessage = this.forecastMessageTarget
    forecastMessage.style.display = 'block' // Show the message container
    forecastMessage.textContent = message
  }
}
