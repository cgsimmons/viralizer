Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'

  resources :analysis, only: [:index, :create]

  mount ResqueWeb::Engine => '/resque_web' unless Rails.env.production?
end
