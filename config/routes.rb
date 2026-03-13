Rails.application.routes.draw do
  # Redirect www to bare domain
  constraints(host: "www.snowway.app") do
    match "(*any)", to: redirect(subdomain: "", path: "/%{any}"), via: :all
    root to: redirect(subdomain: ""), via: :all
  end

  root "home#index"

  resources :resorts, only: [ :index, :show ]
  resources :weather, only: [ :index ]

  # Refresh forecast data
  post "refresh_forecasts", to: "weather#refresh"

  get "sitemap.xml" => "sitemaps#index", defaults: { format: :xml }

  get "up" => "rails/health#show", as: :rails_health_check
end
