Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, singular: :user, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  devise_scope :user do
    get '/user', to: 'users/sessions#show'
  end

  root 'projects#index'

  resources :projects do
    resources :tasks
    resources :sections do
      get '/tasks', to: 'tasks#section_index'
      post '/move_task', to: 'sections#move_task'
    end
  end
end
