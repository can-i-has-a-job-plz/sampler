# frozen_string_literal: true
require 'concurrent/map'

module Sampler
  class EventProcessor # :nodoc:
    attr_reader :events

    def initialize
      @events = Concurrent::Map.new { |m, k| m[k] = Concurrent::Array.new }
    end
  end
end
