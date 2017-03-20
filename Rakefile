# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i(rubocop db:reset spec)
