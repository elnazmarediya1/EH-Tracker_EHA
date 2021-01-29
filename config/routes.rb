Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  root 'welcome#index'
  get 'welcome/index'

  get 'events/past'
  get 'user_events/past'

  get 'leaderboards/index'

  get 'users/export_csv'

  get 'help_doc/index'

  resources :users do
    member do
      get :confirm_email
      get :delete
    end
  end

  resources :events do
    member do
      get :delete
    end
  end

  resources :event_types do
    member do
      get :delete
    end
  end

  resources :user_events, path_names: { new: 'new/:event_id' } do
    member do
      get :delete
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
