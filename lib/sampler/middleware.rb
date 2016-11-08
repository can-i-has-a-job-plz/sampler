# frozen_string_literal: true
require 'active_support/notifications'

module Sampler
  # Rack middleware for request sampling
  class Middleware
    def initialize(app)
      @app = app
    end

    # rubocop:disable Lint/RescueException, Metrics/MethodLength
    def call(env)
      payload = payload_from_request(env)
      instrumenter.start('request.sampler', nil)
      response = @app.call(env)
      payload.merge!(payload_from_response(response))
      response
    rescue Exception
      payload[:response] = ActionDispatch::Response.new
      payload[:response_body] = ''
      raise
    ensure
      instrumenter.finish('request.sampler', payload)
    end
    # rubocop:enable Lint/RescueException, Metrics/MethodLength

    private

    def instrumenter
      Sampler::Notifications.instrumenter
    end

    def payload_from_request(env)
      request = ActionDispatch::Request.new(env.dup)
      # TODO: HashWithIndifferentAccess?
      # TODO: do we want values from request or from env?
      # TODO: is url with query string ok for us?
      # TODO: is request.path ok for endpoint?
      # TODO: what should we do if exception was raised?
      # TODO: should we save HTTP code?
      payload = { endpoint: request.path, url: request.url,
                  method: request.method_symbol, params: request.params,
                  request: request, request_body: request.body.read }
      request.body.rewind
      payload
    end

    def payload_from_response(app_response)
      response = ActionDispatch::Response.new(*app_response)
      { response: response, response_body: response.body }
    end
  end
end
