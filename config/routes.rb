Rails.application.routes.draw do
  get 'meigens/show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "top#index"
  resources :categories
  get '/meigen_show_by_category', to: 'meigens#show_by_category'
  get '/set_meigen_for_schedule_to_session', to: 'meigens#set_meigen_for_schedule_to_session'
  get '/async_find_meigen_by_schedule', to: 'meigens#async_find_meigen_by_schedule'
  get '/schedule_categories', to: 'categories#index_schedule_category'
  get '/show_schedule_categories', to: 'categories#show_schedule_category'
end
