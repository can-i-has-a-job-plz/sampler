# frozen_string_literal: true
module Sampler
  # Stores runtime Sampler configuration information.
  # @example Standard settings
  #     Sampler.configure do |config|
  #       config.probe_class = Sample
  #       config.whitelist << 'example.com'
  #       config.blacklist << 'example.org'
  #     end
  class Configuration
    attr_reader :probe_class, :probe_orm, :whitelist, :blacklist

    def initialize
      @whitelist = FilterSet.new
      @blacklist = FilterSet.new
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
