# frozen_string_literal: true
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

DUMMY_DIR = File.expand_path('../rails_root', __FILE__)

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i(remove_dummy rubocop spec create_and_test_dummy)

desc 'removes dummy rails application'
task :remove_dummy do
  FileUtils.rm_rf(DUMMY_DIR)
end

desc 'creates dummy rails app'
task :create_dummy do
  system 'thor', 'create_dummy_app'
end

desc 'runs specs from /rails_spec/ against dummy rails app'
task :test_dummy do
  dir = Dir.pwd
  Dir.chdir(DUMMY_DIR)
  Bundler.with_clean_env do
    system('bundle exec rake spec') || exit(1)
  end
  Dir.chdir(dir)
end

task :create_and_test_dummy do
  Rake::Task[:create_dummy].execute
  Rake::Task[:test_dummy].execute
  Rake::Task[:remove_dummy].execute
end
