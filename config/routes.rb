Rails.application.routes.draw do

  scope :api do
    scope :v1 do
      resources :notes, only: [:index, :create, :show]
      resources :categories, only: [:index, :create, :show, :update, :destroy]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
