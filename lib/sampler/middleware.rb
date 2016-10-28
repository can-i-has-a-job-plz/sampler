# frozen_string_literal: true
require 'active_support/notifications'

module Sampler
  # Rack middleware for request sampling
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      payload = payload_from_request(env)
      instrumenter.start('request.sampler', nil)
      @app.call(env)
    ensure
      instrumenter.finish('request.sampler', payload)
    end

    private

    def instrumenter
      ActiveSupport::Notifications.instrumenter
    end

    def payload_from_request(env)
      request = ActionDispatch::Request.new(env.dup)
      # TODO: HashWithIndifferentAccess?
      # TODO: do we want values from request or from env?
      # TODO: is url with query string ok for us?
      # TODO: is request.path ok for endpoint?
      { endpoint: request.path, url: request.url, method: request.method_symbol,
        params: request.params, request: request }
    end
  end
end
