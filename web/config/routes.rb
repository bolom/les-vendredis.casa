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
    resources :journal_posts, except: [ :show, :destroy ]
    root "dashboard#show"
    resources :booking_inquiries, only: [ :index, :show ] do
      post :accept, on: :member
      post :decline, on: :member
    end
    resources :availability_blocks, except: :destroy do
      post :cancel, on: :member
    end
    resource :stay_rule, only: [ :edit, :update ]
    resources :calendar_imports, only: :index do
      post :sync, on: :member
    end
  end

  resource :session
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
