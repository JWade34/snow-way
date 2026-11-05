Rails.application.routes.draw do
  root "home#index"

  resources :resorts, only: [ :index, :show ]
  resources :weather, only: [ :index ]

  get "sitemap.xml" => "sitemaps#index", defaults: { format: :xml }
  get "llms.txt" => "llms#index", defaults: { format: :text }
  get "llms-full.txt" => "llms#full", defaults: { format: :text }

  get "up" => "rails/health#show", as: :rails_health_check
end
