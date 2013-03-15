TogoStanza::Application.routes.draw do
  root to: 'demo#index'

  get '/stanza/:id.json'                 => 'api/stanza#show'
  get '/stanza/:stanza_id/resources/:id' => 'api/stanza/resources#show'

  resources :stanza, only: %w(index show) do
    get :help
  end

  namespace :api do
    resources :stanza, only: %w(show) do
      resources :resources, only: %w(show), controller: 'stanza/resources'
    end
  end
end
