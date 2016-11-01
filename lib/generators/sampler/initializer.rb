# frozen_string_literal: true
require 'rails/generators/base'

module Sampler
  module Generators
    # @private
    class InitializerGenerator < Rails::Generators::Base
      argument :model_name, type: :string, default: 'Sample'
      source_root File.expand_path('../../templates', __FILE__)
      desc 'This generator creates Sampler initializer file'

      def create_initializer
        template 'initializer.rb', 'config/initializers/sampler.rb'
      end
    end
  end
end
