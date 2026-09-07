Rails.application.routes.draw do
  post "signup" => "users#create", as: :signup
  resource :session, only: %i[ create destroy ]
  resources :passwords, param: :token, only: %i[ create update ]

  scope :api do
    scope :v1 do
      resources :notes, only: [ :index, :create, :show ]
      resources :categories, only: [ :index, :create, :show, :update, :destroy ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
