Rails.application.routes.draw do
  root "home#index"

  resources :resorts, only: [ :index, :show ]
  resources :weather, only: [ :index ]

  get "up" => "rails/health#show", as: :rails_health_check
end
