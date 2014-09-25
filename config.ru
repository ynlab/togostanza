require 'bundler'

env = ENV['RACK_ENV'] || :development
Bundler.require :default, env

begin
  log = open(File.expand_path("../log/#{env}.log", __FILE__), 'a+').tap {|f| f.sync = true }
rescue
  # Heroku don't allow local file access
  log = $stdout
end

TogoStanza.configure do |config|
  config.text_search_method = ENV['TEXT_SEARCH_METHOD'] || :regex # :regex, :contains, :bif_contains
end

use Rack::CommonLogger, log

map '/stanza/assets' do
  run TogoStanza.sprockets
end

map '/stanza' do
  run TogoStanza::Application
end
