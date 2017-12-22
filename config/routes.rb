Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # route for bin index
  resources :bins, only: [:index]

end
