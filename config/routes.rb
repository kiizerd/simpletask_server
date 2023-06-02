Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' },
                     defaults: { format: :json }

  # Defines the root path route ("/")
  root 'projects#index'

  resources :projects do
    resources :tasks
    resources :sections do
      get '/tasks', to: 'tasks#section_index'
    end
  end

  post 'sections/:id/move_task', to: 'sections#move_task'
end
