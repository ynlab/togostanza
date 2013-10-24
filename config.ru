require 'bundler'
Bundler.require :default, ENV['RACK_ENV'] || :development

map '/stanza/assets' do
  run TogoStanza.sprockets
end

map '/stanza' do
  run TogoStanza::Application
end
