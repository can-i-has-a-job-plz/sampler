# frozen_string_literal: true
require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'
require_relative 'sample_model'
require_relative 'initializer'
require_relative 'controller'

module Sampler
  module Generators
    # @private
    class InstallGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      argument :name, type: :string, default: 'Sample'
      desc 'This generator creates Sampler files'

      def generate_all
        # TODO: `generate` smells funny, maybe we should use `invoke` here
        generate 'sampler:sample_model', name
        generate 'sampler:initializer', name
        generate 'sampler:controller', controller_name
      end
    end
  end
end