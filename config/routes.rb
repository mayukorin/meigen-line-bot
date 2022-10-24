Rails.application.routes.draw do
  get 'meigens/show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "top#index"
  resources :categories
  get '/meigen_show_by_category', to: 'meigens#show_by_category'
end
