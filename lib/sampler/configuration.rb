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
  end
end
