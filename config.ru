require 'bundler/setup'
require 'togostanza-server'

TogoStanza::Stanza.load_all!

map '/stanza' do
  run TogoStanza::Application
end
