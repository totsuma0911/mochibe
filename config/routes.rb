Rails.application.routes.draw do
  root "home#index"
  
  get "up" => "rails/health#show", as: :rails_health_check
  resources :chats, only: [:index, :show, :new, :create]
end
