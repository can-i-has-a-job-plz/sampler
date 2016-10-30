# frozen_string_literal: true
require 'set'

module Sampler
  class FilterClassNotSupported < ArgumentError; end

  class FilterSet < Set # :nodoc:
    SUPPORTED_CLASSES = [String, Regexp, Proc].freeze

    # TODO: should we override/test initialize/merge/replace?
    #   they all use #add in MRI/Jruby

    def add(filter)
      return super if supported?(filter)
      raise FilterClassNotSupported, 'Unsupported filter class'
    end

    private

    def supported?(filter)
      SUPPORTED_CLASSES.include?(filter.class)
    end
  end
end
