Rails.application.routes.draw do
  namespace :tolk do
    resources :locales do
      member do
        get :all
        get :updated
      end
    end
    resource :search
    root :to => 'locales#index'
  end
end

