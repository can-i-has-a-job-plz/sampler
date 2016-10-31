# frozen_string_literal: true
require 'active_support/notifications/fanout'

module Sampler
  class Event < ActiveSupport::Notifications::Event # :nodoc:
    PAYLOAD_KEYS = %i(endpoint url method params request request_body response
                      response_body).freeze

    PAYLOAD_KEYS.each do |m|
      define_method(m) { payload[m] }
    end

    def whitelisted?
      config.whitelist.match(self)
    end

    def blacklisted?
      config.blacklist.match(self)
    end

    def tags
      @tags ||= config.tags.keys.select { |k| config.tags.fetch(k).match(self) }
    end

    private

    def config
      Sampler.configuration
    end
  end
end
