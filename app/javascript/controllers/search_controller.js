import { Controller } from "@hotwired/stimulus"
import { fetch } from "whatwg-fetch"

export default class extends Controller {
  static targets = ["input", "suggestions", "spinner"]

  selectedTags = []

  connect() {
    // Clear previous state
    this.selectedTags = []
  }

  // Called when the user types into the search bar
  async search() {
    const query = this.inputTarget.value

    if (query.length > 2) {  // Trigger search if query length is greater than 2 characters
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
        li.textContent = suggestion
        li.classList.add("list-group-item", "list-group-item-action", "cursor-pointer")
        
        // Event listener to populate input with selected suggestion
        li.addEventListener("click", () => {
          this.addTag(suggestion)
          this.removeSuggestion(suggestion)  // Remove the selected suggestion from the list
        })

        this.suggestionsTarget.appendChild(li)
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
      badge.classList.add("badge", "bg-primary", "me-2", "mb-2", "position-relative")

      // Tag text
      badge.textContent = tag

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
      if (item.textContent === suggestion) {
        item.remove()  // Remove the suggestion from the list
      }
    })
  }
}
