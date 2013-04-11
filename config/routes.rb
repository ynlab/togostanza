TogoStanza::Application.routes.draw do
  resources :stanza, only: %w(index show), path: '/', constraints: {format: 'html'} do
    get :help
  end

  namespace :api, path: '/' do
    resources :stanza, only: %w(show), path: '/' do
      resources :resources, only: %w(show)
    end
  end
end
