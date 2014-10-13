TapDatRails::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # Static pages - front page
  root :to => "static_pages#home"

  devise_for :users

  match "/how_it_works" => "static_pages#how_it_works"
  match "/legal" => "static_pages#legal"
  match "/privacy" => "static_pages#privacy"
  match "/contact" => "static_pages#contact"
  match "/leader_board" => "static_pages#leader_board"

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'registrations' => 'registrations#create', :as => 'register'
        post 'sessions' => 'sessions#create', :as => 'login'
        delete 'sessions' => 'sessions#destroy', :as => 'logout'
      end
      get 'tasks' => 'tasks#index', :as => 'tasks'
    end
  end
  
  namespace :mobile do
    api :version => 1, :module => "v1" do
      resources :sessions, :only => [:create, :destroy]      
      resources :registrations, :only => [:create]  
      resources :transactions, :only => [:create, :index] 
      resources :users, :only => [:show, :update] do
        collection do
          put 'reset_nickname'
          get 'balance_inquiry'
          put 'cashout'
        end
      end   
      resources :nfc_tags, :only => [:create, :update, :index, :destroy]
      resources :payloads, :except => [:new, :edit]
    end    
  end  
end
