# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: :all

  scope :api, defaults: { format: :json } do
    namespace :v1 do
      devise_scope :user do
        post 'users/sign_in', to: 'sessions#create'
        delete 'users/sign_out', to: 'sessions#destroy'
        post 'users/password', to: 'passwords#create'
        put 'users/password', to: 'passwords#update'
        post 'users/confirmation', to: 'confirmations#create'
        get 'users/confirmation', to: 'confirmations#show'
        post 'users/session-token', to: 'session_tokens#create'
      end

      resources :users, only: %i[index create] do
        patch 'approve', on: :member
        get 'me', on: :collection
        get 'last_edited_project', on: :member
      end

      resources :editorial_remarks, only: %i[index]

      resources :projects, only: %i[index create update show destroy] do
        put :export, on: :member
        resources :witnesses, only: %i[index create update destroy]
        resources :tokens, only: %i[index show] do
          patch 'variants', to: 'tokens#update_variants', on: :member
          patch 'grouped_variants', to: 'tokens#update_grouped_variants', on: :member
          patch 'resize', to: 'tokens#resize', on: :collection
          patch 'split', to: 'tokens#split', on: :member
          get 'edited', to: 'tokens#edited', on: :collection

          resources :comments, only: %i[index create update destroy], on: :member
        end
        resources :insignificant_variants, only: %i[index]
        resources :significant_variants, only: %i[index]
      end
    end
  end

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end
