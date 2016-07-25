require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)
YARD::Rake::YardocTask.new do |t|
  t.stats_options = %w(--list-undoc --compact)
end

task default: [:spec, :rubocop, :yard]
