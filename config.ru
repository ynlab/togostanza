require 'bundler/setup'
require 'togostanza'
require 'variation_stanza'

map '/stanza' do
  run TogoStanza::Application
end
