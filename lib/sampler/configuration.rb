# frozen_string_literal: true

require 'set'
require 'logger'

module Sampler
  class Configuration # :nodoc:
    attr_reader :whitelist, :blacklist
    attr_accessor :logger

    def initialize
      @running = false
      # TODO: we should check that blacklisted values is_a?(String), but there
      #   will not be any issues if user will add other object, so skip for now
      @whitelist = /\a\Z/
      @blacklist = Set.new
      @logger = Logger.new(nil)
    end

    def whitelist=(value)
      return @whitelist = value if value.respond_to?(:match?)
      raise ArgumentError, 'whitelist should respond_to?(:match?)'
    end

    def tag_with(name, filter)
      if filter.nil? then tags.delete(name)
      elsif filter.respond_to?(:call) && filter.respond_to?(:arity) &&
            filter.arity.equal?(1)
        tags[name.to_s] = filter
      else raise ArgumentError, 'tag filter should be nil or callable ' \
                                'with arity 1'
      end
    end

    def start
      @running = true
    end

    def stop
      @running = false
    end

    def running?
      @running
    end

    def sampled?(endpoint)
      whitelist.match?(endpoint) && !blacklist.include?(endpoint)
    end

    def tags
      @tags ||= {}
    end
  end
end
