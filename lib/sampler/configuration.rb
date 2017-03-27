# frozen_string_literal: true

require 'set'
require 'logger'
require 'forwardable'

module Sampler
  class Configuration # :nodoc:
    extend Forwardable

    attr_reader :whitelist, :blacklist
    attr_accessor :logger

    def_delegators :storage, :events

    def self.positive_integer_attr(name, allow_nil = true)
      attr_reader name
      define_method("#{name}=") do |n|
        if n.respond_to?(:to_i) && n.to_i.positive?
          return instance_variable_set("@#{name}", n.to_i)
        end
        return instance_variable_set("@#{name}", nil) if allow_nil && n.nil?
        raise ArgumentError, "#{name} should be positive integer" \
                             "#{' or nil' if allow_nil}"
      end
    end

    positive_integer_attr :execution_interval, false
    positive_integer_attr :max_per_endpoint
    positive_integer_attr :max_per_interval

    def initialize
      @running = false
      # TODO: we should check that blacklisted values is_a?(String), but there
      #   will not be any issues if user will add other object, so skip for now
      @whitelist = /\a\Z/
      @blacklist = Set.new
      @logger = Logger.new(nil)
      @execution_interval = 60
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
      executor.execute
    end

    def stop
      executor.kill
      executor.wait_for_termination
      # TODO: save outstanding events
    end

    def running?
      executor.running?
    end

    def sampled?(endpoint)
      whitelist.match?(endpoint) && !blacklist.include?(endpoint)
    end

    def tags
      @tags ||= {}
    end

    def storage
      @storage ||= Storage.new
    end

    private

    def executor
      @executor ||= Concurrent::TimerTask.new(executor_opts) do
        processor.process
      end.with_observer(ExecutorObserver.new)
    end

    def executor_opts
      { execution_interval: execution_interval,
        timeout_interval: execution_interval,
        fallback_policy: :discard,
        run_now: true }
    end

    def processor
      @processor ||= Processor.new
    end
  end
end
