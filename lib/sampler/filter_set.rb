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

    def match(event)
      each do |filter|
        return true if case filter
                       when String then event.url.include?(filter)
                       when Regexp then event.url.match(filter)
                       when Proc then filter.call(event)
                         # TODO: should we do something in else case?
                       end
      end
      false
    end

    private

    def supported?(filter)
      SUPPORTED_CLASSES.include?(filter.class)
    end
  end
end
