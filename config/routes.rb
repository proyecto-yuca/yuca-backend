Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, skip: %i[sessions registrations passwords], defaults: { format: :json }

      devise_scope :user do
        post "auth/sign_in", to: "auth/sessions#create"
        delete "auth/sign_out", to: "auth/sessions#destroy"

        post "auth", to: "auth/registrations#create"
        patch "auth", to: "auth/registrations#update"
        put "auth", to: "auth/registrations#update"
        delete "auth", to: "auth/registrations#destroy"

        post "auth/password", to: "auth/passwords#create"
        patch "auth/password", to: "auth/passwords#update"
        put "auth/password", to: "auth/passwords#update"
      end

      resource :user, only: %i[show update destroy], controller: "users"
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
