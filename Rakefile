# frozen_string_literal: true
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

DUMMY_DIR = File.expand_path('../spec/rails_root', __FILE__)

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i(remove_dummy rubocop spec test_dummy_app)

desc 'removes dummy rails application'
task :remove_dummy do
  FileUtils.rm_rf(DUMMY_DIR)
end

desc 'creates dummy rails application and running specs from ' \
     'spec/inside_rails  against it'
task :test_dummy_app do
  system 'thor', 'create_dummy_app'
  Dir.chdir(DUMMY_DIR) do
    Bundler.with_clean_env do
      system('bundle exec rake spec') || exit(1)
    end
  end
  Rake::Task[:remove_dummy].execute
end
