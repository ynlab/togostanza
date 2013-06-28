source 'https://rubygems.org'

gem 'rails'

gem 'action_args'
gem 'flavour_saver', github: 'jamesotron/FlavourSaver' # wait for 0.4.0 release
gem 'haml-rails'
gem 'hashie'
gem 'jquery-rails'
gem 'parallel'
gem 'pg'
gem 'redcarpet'
gem 'sparql-client'
gem 'unicorn'
gem 'bio-svgenes', '>= 0.3.3'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
end

group :development do
  gem 'launchy', require: false
  gem 'mina', require: false
  gem 'pry', group: 'test'
  gem 'tapp', group: 'test'
  gem 'zeus', require: false
end

group :test do
  gem 'capybara'
  gem 'json_spec'

  group :development do
    gem 'rspec-rails'
  end
end
