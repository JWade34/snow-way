Rails.application.routes.draw do
  root "home#index"

  resources :resorts, only: [ :index, :show ]
  resources :weather, only: [ :index ]

  # Refresh forecast data

  get "sitemap.xml" => "sitemaps#index", defaults: { format: :xml }

  get "up" => "rails/health#show", as: :rails_health_check
end
