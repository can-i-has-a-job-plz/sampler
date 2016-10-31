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
    attr_reader :probe_class, :probe_orm, :whitelist, :blacklist, :tags

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

    private

    def orm_for_class(klass)
      # TODO: suggest to file an issue
      raise ArgumentError, 'Unsupported ORM' unless klass < ActiveRecord::Base
      :active_record
    end
  end
end
