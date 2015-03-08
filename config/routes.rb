Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # Static pages - front page
  root :to => "static_pages#home"

  devise_for :users

  resources :users, :only => [:update] do
    member do
      get 'leader_board'
      get 'dashboard'
      get 'qrcode'
    end
  end

  resources :currencies do
    get 'leader_board', :on => :member
  end
  
  resources :vouchers, :except => [:edit, :update]
  resources :single_code_generators, :only => [:index, :show, :destroy]
  resources :nfc_tags
  
  get "/how_it_works" => "static_pages#how_it_works"
  get "/legal" => "static_pages#legal"
  get "/privacy" => "static_pages#privacy"
  get "/contact" => "static_pages#contact"
  get "/leader_board" => "static_pages#leader_board"

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
        
        put 'redeem_voucher', :on => :member
      end
      resources :nfc_tags, :only => [:create, :update, :index, :destroy]
      resources :payloads, :except => [:new, :edit]
      resources :currencies, :only => [:show, :index]
      
      resources :device_logs, :only => [:create]
      
      get 'ping' => "static_api#ping"
    end
  end
end
