ENV['RACK_ENV'] ||= 'test'

require 'capybara'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = %i(should expect)
  end

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.include Capybara::DSL
end

Capybara.app = Rack::Builder.parse_file(File.expand_path("../../config.ru", __FILE__)).first
