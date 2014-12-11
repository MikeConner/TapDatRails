Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # Static pages - front page
  root :to => "static_pages#home"

  devise_for :users

  resources :users, :only => [] do
    get 'leader_board', :on => :member
  end
  
  resources :currencies
  resources :vouchers
  
  get "/how_it_works" => "static_pages#how_it_works"
  get "/legal" => "static_pages#legal"
  get "/privacy" => "static_pages#privacy"
  get "/contact" => "static_pages#contact"
  get "/leader_board" => "static_pages#leader_board"

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
      resources :currencies, :only => [:index]
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
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
