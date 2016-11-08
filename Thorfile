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
      run_with_clean_env 'bundle exec rake db:drop db:create db:migrate'
      create_controller
      create_routes
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
      gem 'factory_girl_rails'
      gem 'capybara'
    EOF
  end

  # rubocop:disable Metrics/MethodLength
  def configure_rspec
    gsub_file '.rspec', 'spec_helper', 'rails_helper'
    append_to_file 'spec/rails_helper.rb', <<~EOF
      Shoulda::Matchers.configure do |config|
        config.integrate do |with|
          with.test_framework :rspec
          with.library :rails
        end
      end
      require 'capybara/rspec'
    EOF
    inject_into_file 'spec/rails_helper.rb', after: /RSpec.configure.*\n/ do
      <<~EOF
        config.include FactoryGirl::Syntax::Methods

        config.before do
          Sampler.configuration.whitelist.clear
          Sampler.configuration.tags.clear
          Sampler.configuration.max_probes_per_hour = nil
          Sampler.configuration.max_probes_per_endpoint = nil
          Sample.delete_all
        end
      EOF
    end
    gsub_file 'spec/rails_helper.rb', /.*use_transactional_fixtures/, '# \1'
  end
  # rubocop:enable Metrics/MethodLength

  def copy_specs
    directory('rails_spec', File.join(DUMMY_DIR, 'spec'), force: true)
  end

  def create_controller
    run_with_clean_env 'bundle exec rails g controller whatever ' \
                       '--no-test-framework'
    file_name = 'app/controllers/whatever_controller.rb'
    inject_into_class file_name, 'WhateverController', <<~EOF
      def index
        render plain: "whatever_\#{params[:reply]}"
      end
    EOF
  end

  def create_routes
    insert_into_file 'config/routes.rb', before: /^end$/ do
      %i(get post patch put delete).map do |m|
        "  #{m} '/*whatever', to: 'whatever#index'\n"
      end.join
    end
  end
end
