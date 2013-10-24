require 'bundler'

env = ENV['RACK_ENV'] || :development
Bundler.require :default, env

log = open(File.expand_path("../log/#{env}.log", __FILE__), 'a+').tap {|f| f.sync = true }

use Rack::CommonLogger, log

map '/stanza/assets' do
  run TogoStanza.sprockets
end

map '/stanza' do
  run TogoStanza::Application
end
