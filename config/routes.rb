Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # route for bin index
  resources :bins, only: [:index, :create]

  # route for user create
  resources :users, only: [:index, :create]

  # route for user_bins create
  resources :user_bins, only: [:index, :create]

  get '/user_bins/community_data', to: 'user_bins#community_data', as: 'community_data'

  get '/users/auth', to: 'users#auth', as: 'auth'

end
