Rails.application.routes.draw do
  match 'login' => "wulin_oauth/user_sessions#new", :as => :login, :via => :get
  match 'login' => "wulin_oauth/user_sessions#create", :as => :login, :via => :post
  match 'logout' => "wulin_oauth/user_sessions#destroy", :as => :logout
  match 'oauth/callback' => "wulin_oauth/user_sessions#callback", :as => :callback, :via => :get
  match 'clear_users_cache' => "wulin_oauth/user_sessions#clear_cache", :as => :clear_users_cache, :via => :post
end