Rails.application.routes.draw do
  get "sitemap_index.xml" => "discovery#sitemap_index"
  get "sitemap.xml" => "discovery#sitemap"
  get "fr/sitemap.xml" => "discovery#sitemap", defaults: { locale: "fr" }
  get "feed.xml" => "discovery#feed"
  get "llms.txt" => "discovery#llms"
  get ".well-known/agent.json" => "discovery#agent"
  root "pages#home"
  get "fr" => "pages#home", defaults: { locale: "fr" }, as: :french_home
  get "journal" => "journal_posts#index", defaults: { locale: "en" }, as: :journal
  get "journal/:slug" => "journal_posts#show", defaults: { locale: "en" }, as: :journal_post
  get "fr/journal" => "journal_posts#index", defaults: { locale: "fr" }, as: :french_journal
  get "fr/journal/:slug" => "journal_posts#show", defaults: { locale: "fr" }, as: :french_journal_post
  get "availability" => "availability#show"
  get "rules" => "machine_bookings#rules"
  post "quote" => "machine_bookings#quote"
  post "book" => "machine_bookings#book"
  resources :booking_inquiries, only: [ :new, :create, :show ], path: "booking-requests"

  namespace :admin do
    root "dashboard#show"
    get "calendar", to: "calendar#show", as: :calendar
    get "calendar/day", to: "calendar#day", as: :calendar_day
    get "calendars", to: "calendars#index", as: :calendars
    get "diagnostics", to: "diagnostics#index", as: :diagnostics
    get "notifications", to: "notifications#index", as: :notifications
    resources :content_pages
    resources :users
    resources :payment_orders, only: [ :index, :show, :update ]
    resources :journal_posts, except: [ :show, :destroy ]
    resources :booking_inquiries, only: [ :index, :show ] do
      post :accept, on: :member
      post :decline, on: :member
      post :cancel, on: :member
    end
    resources :availability_blocks, only: [ :index, :new, :create ] do
      post :cancel, on: :member
    end
    resource :stay_rule, only: [ :edit, :update ]
    resources :calendar_imports, only: [] do
      post :sync, on: :member
    end
  end

  resource :session

  # Agent (machine) API: Bearer-token auth, separate from human web sessions.
  namespace :agent do
    get "house", to: "state#house"
    get "calendar", to: "state#calendar"
    get "booking_requests", to: "state#booking_requests"
    get "booking_requests/:id", to: "state#booking_request"

    post "blocks", to: "actions#block_dates"
    post "blocks/:id/cancel", to: "actions#cancel_block"
    post "booking_requests", to: "actions#record_booking"
    post "booking_requests/:id/accept", to: "actions#accept_booking"
    post "booking_requests/:id/decline", to: "actions#decline_booking"
    post "booking_requests/:id/cancel", to: "actions#cancel_booking"
    patch "stay_rules", to: "actions#update_stay_rules"
    post "calendar_syncs", to: "actions#sync_calendars"
  end

  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "*path" => "content_pages#show", as: :content_page

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
