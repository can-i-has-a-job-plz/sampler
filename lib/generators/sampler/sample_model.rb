# frozen_string_literal: true
require 'rails/generators/named_base'

module Sampler
  module Generators
    # @private
    class SampleModelGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers
      hook_for :orm
      # TODO: handle missing ORM support and suggest to file an issue
    end
  end
end
