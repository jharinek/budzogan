Budzogan::Application.routes.draw do
  authenticated :user do
    root 'tasks#index', as: :authenticated
  end

  root 'static_pages#home'

  devise_for :users, path: '', path_names: { sign_up: :join, sign_in: :login, sign_out: :logout }

  resources :tasks

  resources :workgroups

  resources :exercises, only: [:create, :edit, :index] do
    resources :build, controller: 'exercises/build'
  end

  get 'sentences/generate', controller: 'sentences/generate'
end
