Rails.application.routes.draw do
  root "home#index"

  resources :resorts, only: [ :index, :show ] do
    get "best-time-to-ski", on: :member, to: "resorts#best_time", as: :best_time
  end
  resources :weather, only: [ :index ]

  get "where-is-it-snowing" => "pages#where_is_it_snowing", as: :where_is_it_snowing
  get "ikon-vs-epic" => "pages#ikon_vs_epic", as: :ikon_vs_epic
  get "epic-pass-resorts" => "pages#pass_resorts", defaults: { pass: "epic" }, as: :epic_pass_resorts
  get "ikon-pass-resorts" => "pages#pass_resorts", defaults: { pass: "ikon" }, as: :ikon_pass_resorts
  get "indy-pass-resorts" => "pages#pass_resorts", defaults: { pass: "indy" }, as: :indy_pass_resorts
  get "ski-resort-opening-dates" => "pages#opening_dates", as: :opening_dates
  get "about" => "pages#about", as: :about
  get "authors/justin-mckelvey" => "pages#author", as: :author
  get "powder-report" => "powder_reports#current", as: :powder_report
  get "powder-report/:id" => "powder_reports#show", as: :powder_report_archive, constraints: { id: /\d{4}-\d{2}-\d{2}/ }
  resources :subscribers, only: [ :create ]
  match "unsubscribe/:token" => "subscribers#unsubscribe", via: [ :get, :post ], as: :unsubscribe
  get "powder-calendar" => "lead_magnets#powder_calendar", as: :powder_calendar
  get "powder-calendar/download/:token" => "lead_magnets#download", as: :powder_calendar_download, defaults: { magnet: "powder-calendar" }
  get "downloads/:magnet/:token" => "lead_magnets#download", as: :lead_magnet_download
  get "ski-trip-planner" => "lead_magnets#ski_trip_planner", as: :ski_trip_planner
  get "affiliate-disclosure" => "pages#affiliate_disclosure", as: :affiliate_disclosure
  get "ski-resorts" => "regions#index", as: :regions
  get "ski-resorts/:id" => "regions#show", as: :region
  get "ski-resorts-near-me" => "hubs#near_me", as: :near_me
  get "ski-resorts-near/:id" => "hubs#show", as: :hub
  get "guides/:topic" => "guides#topic", as: :guide_topic, constraints: { topic: Regexp.union(GuideTopic::TOPICS.keys) }
  resources :guides, only: [ :index, :show ]
  get "snowboard-size-chart" => "tools#snowboard_size", as: :snowboard_size_chart
  get "ski-size-chart" => "tools#ski_size", as: :ski_size_chart

  get "widget" => "embeds#widget", as: :widget
  get "embed/powder-rankings" => "embeds#powder_rankings", as: :embed_powder_rankings
  get "og/resorts/:id.png" => "og_images#resort", as: :resort_og_image

  get "sitemap.xml" => "sitemaps#index", defaults: { format: :xml }
  get "llms.txt" => "llms#index", defaults: { format: :text }
  get "llms-full.txt" => "llms#full", defaults: { format: :text }
  get "#{IndexNow::KEY}.txt" => ->(_env) { [ 200, { "content-type" => "text/plain" }, [ IndexNow::KEY ] ] }

  get "what-i-ride" => "pages#gear", as: :gear
  post "t/a" => "tracking#affiliate", as: :track_affiliate

  namespace :admin do
    root "dashboard#show"
    get "growth" => "growth#show", as: :growth
    resources :visits, only: [ :index, :edit, :update ], param: :slug, path: "resorts"
    patch "resorts" => "visits#checklist", as: :visits_checklist
    get "import" => "imports#new", as: :import
    post "import" => "imports#create"
    resources :gear_items, path: "gear", except: [ :show ]
    resources :subscribers, only: [ :index ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
