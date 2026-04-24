Rails.application.routes.draw do
  root to: "root#show"

  get "up" => "rails/health#show", as: :rails_health_check

  mount ActionCable.server => "/cable"

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      get "auth/me", to: "auth#me"
      resources :shared_videos, only: %i[ index create destroy ]
    end
  end
end
