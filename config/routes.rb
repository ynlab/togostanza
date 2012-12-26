TogoStanza::Application.routes.draw do
  root to: 'stanza#index'
  resources :stanza, only: %w(show)
end
