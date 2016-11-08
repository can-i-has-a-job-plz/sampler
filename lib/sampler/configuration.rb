# frozen_string_literal: true
require 'active_support/hash_with_indifferent_access'

module Sampler
  # Stores runtime Sampler configuration information.
  # @example Standard settings
  #     Sampler.configure do |config|
  #       config.probe_class = Sample
  #       config.whitelist << 'example.com'
  #       config.blacklist << 'example.org'
  #       config.tag_with 'slow', ->(event) { event.duration > 200 }
  #     end
  class Configuration
    attr_reader :probe_class, :probe_orm, :whitelist, :blacklist, :tags

    def self.positive_integer_attr(name)
      attr_reader name
      define_method("#{name}=") do |n|
        if n.nil? || (n.is_a?(Integer) && n.positive?)
          return instance_variable_set("@#{name}", n)
        end
        raise ArgumentError, "#{name} should be positive integer"
      end
    end

    positive_integer_attr :max_probes_per_hour
    positive_integer_attr :max_probes_per_endpoint

    def initialize
      @whitelist = FilterSet.new
      @blacklist = FilterSet.new
      @tags = HashWithIndifferentAccess.new
    end

    def tag_with(name, filter)
      # TODO: check tag_filter for arity if Proc?
      unless name.is_a?(String) || name.is_a?(Symbol)
        raise ArgumentError, 'tag name should be a String or a Symbol'
      end
      return (@tags[name] ||= FilterSet.new) << filter if filter.is_a?(Proc)
      raise ArgumentError, 'filter should be a Proc'
    end

    def probe_class=(klass)
      # TODO: should we initialize it to some default value?
      # TODO: check if it's really a Class (not Module etc)?
      @probe_orm = orm_for_class(klass)
      @probe_class = klass
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
