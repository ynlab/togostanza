TogoStanza::Application.routes.draw do
  root to: 'demo#index'

  get '/stanza/:id.json' => 'api/stanza#show'

  resources :stanza, only: %w(index show) do
    get :help
  end

  namespace :api do
    resources :stanza, only: %w(show)
  end
end
