Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "projects#index"

  resources :projects do
    resources :tasks
    resources :sections do
      get '/tasks', to: 'tasks#section_index'
    end
  end
end
