# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "yard"

YARD::Rake::YardocTask.new do |t|
  t.stats_options = ["--list-undoc"]
end

task doc: :yard

task default: %i[spec rubocop doc]
