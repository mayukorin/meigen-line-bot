Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "top#index"
  resources :gachas, only: [:index, :show]
  get '/schedule_gacha/schedules/new', to: 'gachas#new_schedule'
  get '/schedule_gacha/show', to: 'gachas#show_schedule_gacha'
  get '/meigen_take_out', to: 'meigens#take_out'
  get '/select_by_schedule', to: 'meigens#select_by_schedule'
  get '/select_by_random_or_original', to: 'meigens#select_by_random_or_original'

  post '/callback', to: 'linebot#callback'
end
