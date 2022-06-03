# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: :all

  scope :api, defaults: { format: :json } do
    namespace :v1, module: :ver1 do
      devise_scope :user do
        post 'users/sign_in', to: 'sessions#create'
        delete 'users/sign_out', to: 'sessions#destroy'
        post 'users/password', to: 'passwords#create'
        put 'users/password', to: 'passwords#update'
      end

      get 'users', to: 'users#index'
      post 'users', to: 'users#create'
      patch 'users/:id/approve', to: 'users#approve'
    end
  end

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end
