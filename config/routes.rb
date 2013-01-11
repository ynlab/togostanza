TogoStanza::Application.routes.draw do
  root to: 'demo#index'
  resources :stanza, only: %w(show)
end
