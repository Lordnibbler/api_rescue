Rails.application.routes.draw do
  resources :test, only: [:index]
end
