# frozen_string_literal: true
require 'rails/generators/base'
require_relative 'sample_model'

module Sampler
  module Generators
    # @private
    class InstallGenerator < Rails::Generators::Base
      argument :model_name, type: :string, default: 'Sample'
      desc 'This generator creates Sampler files'

      def generate_all
        # TODO: `generate` smells funny, maybe we should use `invoke` here
        generate 'sampler:sample_model', model_name
      end
    end
  end
end
