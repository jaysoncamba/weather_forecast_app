Rails.application.routes.draw do
  root "home#index"
  get 'locations/search', to: 'locations#search'
end
