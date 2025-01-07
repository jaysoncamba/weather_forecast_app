Rails.application.routes.draw do
  root "home#index"
  get "locations/search"
  post "locations/forecast"
end
