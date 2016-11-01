# frozen_string_literal: true
class TestDummyApp < Thor # :nodoc:
  include Thor::Actions

  SKIP_ARGS = %w(bundle git keeps action-mailer puma action-cable sprockets
                 spring listen javascript turbolinks
                 test).map { |s| "--skip-#{s}" }.freeze

  DUMMY_DIR = File.expand_path('../spec/rails_root', __FILE__)

  namespace :default
  source_root File.dirname(__FILE__)

  desc 'create_dummy_app', 'Creates dummy rails app to runs specs against it'
  def create_dummy_app
    create_rails_app
    inside(DUMMY_DIR) do
      prepare_gemfile
      run_with_clean_env 'bundle install'
      run_with_clean_env 'bundle exec rails g sampler:install'
      run_with_clean_env 'bundle exec rails db:drop db:create db:migrate'
    end
    install_rspec
  end

  private

  def run_with_clean_env(command)
    Bundler.with_clean_env { run command }
  end

  def install_rspec
    inside(DUMMY_DIR) do
      run_with_clean_env 'bundle exec rails g rspec:install'
      configure_rspec
    end
    copy_specs
  end

  def create_rails_app
    remove_dir DUMMY_DIR
    args = [DUMMY_DIR, '--database=postgresql', *SKIP_ARGS].join(' ')
    run_with_clean_env "bundle exec rails new #{args}"
  end

  def prepare_gemfile
    append_to_file 'Gemfile', <<~EOF
      gem 'rspec-rails'
      gem 'shoulda-matchers'
      gem 'sampler', path: '../..'
    EOF
  end

  def configure_rspec
    gsub_file '.rspec', 'spec_helper', 'rails_helper'
    append_to_file 'spec/rails_helper.rb', <<~EOF
      Shoulda::Matchers.configure do |config|
        config.integrate do |with|
          with.test_framework :rspec
          with.library :rails
        end
      end
    EOF
  end

  def copy_specs
    directory('rails_spec', File.join(DUMMY_DIR, 'spec'), force: true)
  end
end
