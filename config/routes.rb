Rails.application.routes.draw do
  get 'meigens/show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "top#index"
  resources :gachas
  get '/meigen_show_by_gacha', to: 'meigens#show_by_gacha'
  get '/set_meigen_for_schedule_to_session', to: 'meigens#set_meigen_for_schedule_to_session'
  get '/async_find_meigen_by_schedule', to: 'meigens#async_find_meigen_by_schedule'
  get '/schedule_gachas', to: 'gachas#index_schedule_gacha'
  get '/show_schedule_gachas', to: 'gachas#show_schedule_gacha'
end
