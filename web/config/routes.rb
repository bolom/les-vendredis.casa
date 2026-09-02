Rails.application.routes.draw do
  root "pages#home"
  get "availability" => "availability#show"
  resources :booking_inquiries, only: [ :new, :create, :show ], path: "booking-requests"

  namespace :admin do
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

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
