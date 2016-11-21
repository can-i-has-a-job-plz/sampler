# frozen_string_literal: true
require 'logger'
require 'set'
require 'active_support/hash_with_indifferent_access'

module Sampler
  # Stores runtime Sampler configuration information.
  # @example Standard settings
  #     Sampler.configure do |config|
  #       config.probe_class = Sample
  #     end
  class Configuration
    attr_reader :probe_class, :probe_orm, :running, :whitelist, :blacklist,
                :tags
    attr_accessor :logger, :event_processor

    def self.positive_integer_attr(name)
      attr_reader name
      define_method("#{name}=") do |n|
        if n.nil? || (n.is_a?(Integer) && n.positive?)
          return instance_variable_set("@#{name}", n)
        end
        raise ArgumentError, "#{name} should be positive integer"
      end
    end

    positive_integer_attr :max_probes_per_endpoint
    positive_integer_attr :max_probes_per_hour

    def initialize
      @logger = Logger.new(nil)
      @event_processor = EventProcessor.new
      @running = false
      # TODO: we should check that blacklisted values is_a?(String), but there
      #   will not be any issues if user will add other object, so skip for now
      @blacklist = Set.new
      @tags = HashWithIndifferentAccess.new
    end

    def tag_with(name, filter)
      unless name.instance_of?(String) || name.instance_of?(Symbol)
        raise ArgumentError, 'tag name should be a String or a Symbol'
      end
      if filter.nil?
        tags.delete(name)
        nil
      elsif filter.instance_of?(Proc) && filter.arity.equal?(1)
        tags[name] = filter
      else raise ArgumentError, 'tag filter should be nil or Proc with arity 1'
      end
    end

    def probe_class=(klass)
      # TODO: should we initialize it to some default value?
      # TODO: check if it's really a Class (not Module etc)?
      @probe_orm = orm_for_class(klass)
      @probe_class = klass
    end

    def start
      @running = true
    end

    def stop
      @running = false
    end

    def whitelist=(regexp)
      return @whitelist = regexp if regexp.nil? || regexp.instance_of?(Regexp)
      raise ArgumentError, 'whitelist should be nil or a Regexp'
    end

    private

    def orm_for_class(klass)
      if defined?(ActiveRecord::Base) && klass < ActiveRecord::Base
        return :active_record
      end
      # TODO: suggest to file an issue
      raise ArgumentError, 'Unsupported ORM'
    end
  end
end
