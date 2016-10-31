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
      Sampler.configuration.whitelist.match(self)
    end

    def blacklisted?
      Sampler.configuration.blacklist.match(self)
    end
  end
end
