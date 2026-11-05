Rails.application.routes.draw do
  root "home#index"

  resources :resorts, only: [ :index, :show ] do
    get "best-time-to-ski", on: :member, to: "resorts#best_time", as: :best_time
  end
  resources :weather, only: [ :index ]

  get "where-is-it-snowing" => "pages#where_is_it_snowing", as: :where_is_it_snowing
  get "ikon-vs-epic" => "pages#ikon_vs_epic", as: :ikon_vs_epic
  get "ski-resort-opening-dates" => "pages#opening_dates", as: :opening_dates
  get "ski-resorts" => "regions#index", as: :regions
  get "ski-resorts/:id" => "regions#show", as: :region
  get "ski-resorts-near/:id" => "hubs#show", as: :hub
  resources :guides, only: [ :index, :show ]

  get "widget" => "embeds#widget", as: :widget
  get "embed/powder-rankings" => "embeds#powder_rankings", as: :embed_powder_rankings
  get "og/resorts/:id.png" => "og_images#resort", as: :resort_og_image

  get "sitemap.xml" => "sitemaps#index", defaults: { format: :xml }
  get "llms.txt" => "llms#index", defaults: { format: :text }
  get "llms-full.txt" => "llms#full", defaults: { format: :text }
  get "#{IndexNow::KEY}.txt" => ->(_env) { [ 200, { "content-type" => "text/plain" }, [ IndexNow::KEY ] ] }

  get "up" => "rails/health#show", as: :rails_health_check
end
