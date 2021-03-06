Rails.application.routes.draw do
  get 'login', to: 'wulin_oauth/user_sessions#new'
  post 'login', to: 'wulin_oauth/user_sessions#create'
  get 'logout', to: 'wulin_oauth/user_sessions#destroy'
  get 'oauth/callback', to: 'wulin_oauth/user_sessions#callback', as: :callback
end
