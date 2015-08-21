Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  constraints(:host => "www.tapdatapp.co") do
    root :to => 'static_pages#club'
  end

  get '/' => "static_pages#home"

  devise_for :users

  resources :users, :only => [:show, :update] do
    member do
      get 'leader_board'
      get 'qrcode'
    end
  end

  resources :currencies do
    member do
      get 'leader_board'
      get 'fast_leader_board'
      get 'report'
      get 'clear_tx'
      put 'update_poll'
    end
  end

  resources :vouchers, :except => [:edit, :update]
  resources :single_code_generators, :only => [:index, :show, :destroy]
  resources :nfc_tags

  get "/how_it_works" => "static_pages#how_it_works"
  get "/legal" => "static_pages#legal"
  get "/privacy" => "static_pages#privacy"
  get "/contact" => "static_pages#contact"
  get "/leader_board" => "static_pages#leader_board"
  get "/thumb_dimensions" => "static_pages#thumb_dimensions"
  # Additional simple path for tag-reading performance
  get "/tag/:id" => "nfc_tags#show"
  
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
      resources :nfc_tags, :except => [:new, :edit]
      resources :payloads, :except => [:new, :edit]
      resources :currencies, :only => [:show, :index]

      resources :device_logs, :only => [:create]

      get 'ping' => "static_api#ping"
    end
  end
end
