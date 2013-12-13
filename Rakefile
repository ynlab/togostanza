require 'bundler/setup'

begin
  require 'rspec/core/rake_task'
rescue
  # do nothing (e.g. production environment)
else
  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
end
