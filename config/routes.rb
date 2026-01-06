Rails.application.routes.draw do
  root "home#index"

  resources :resorts, only: [ :index, :show ]

  get "up" => "rails/health#show", as: :rails_health_check
end
