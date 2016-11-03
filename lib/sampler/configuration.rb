# frozen_string_literal: true
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
    attr_reader :probe_class, :probe_orm, :whitelist, :blacklist, :tags,
                :max_probes_per_hour, :max_probes_per_endpoint

    def initialize
      @whitelist = FilterSet.new
      @blacklist = FilterSet.new
      @tags = {} # TODO: WithIndifferentAccess?
    end

    def tag_with(tag_name, tag_filter)
      # TODO: check if tag_name is a String or stringity it here?
      # TODO: check tag_filter for arity if Proc?
      (@tags[tag_name] ||= FilterSet.new) << tag_filter
    end

    def probe_class=(klass)
      # TODO: should we initialize it to some default value?
      # TODO: check if it's really a Class (not Module etc)?
      @probe_orm = orm_for_class(klass)
      @probe_class = klass
    end

    def max_probes_per_hour=(n)
      if n.nil? || (n.is_a?(Integer) && n.positive?)
        return @max_probes_per_hour = n
      end
      raise ArgumentError, 'We need positive integer here'
    end

    def max_probes_per_endpoint=(n)
      if n.nil? || (n.is_a?(Integer) && n.positive?)
        return @max_probes_per_endpoint = n
      end
      raise ArgumentError, 'We need positive integer here'
    end

    private

    def orm_for_class(klass)
      if klass < ActiveRecord::Base then :active_record
      elsif klass < NilClass then :nil_record
      # TODO: suggest to file an issue
      else raise ArgumentError, 'Unsupported ORM'
      end
    end
  end
end
