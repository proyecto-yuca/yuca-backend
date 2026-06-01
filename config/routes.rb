Rails.application.routes.draw do
  devise_for :users,
             path: "api/v1/auth",
             path_names: {
               sign_in: "sign_in",
               sign_out: "sign_out",
               registration: ""
             },
             defaults: { format: :json },
             controllers: {
               sessions: "api/v1/auth/sessions",
               registrations: "api/v1/auth/registrations",
               passwords: "api/v1/auth/passwords"
             }

  namespace :api do
    namespace :v1 do
      resource :user, only: %i[show update destroy], controller: "users"

      resources :fincas, only: %i[index show create update] do
        member do
          patch :estado
        end

        resources :lecturas, controller: "lecturas_sensor", only: %i[index create] do
          collection do
            get :recientes
          end
        end

        namespace :iot do
          resource :credential, only: :create, controller: "credentials"
        end
      end

      namespace :iot do
        post "lecturas_sensor/sync", to: "lecturas_sync#create"
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
