# frozen_string_literal: true
module Sampler
  # Rack middleware for request sampling
  class Middleware
    RESOLVE_ERROR = 'Got error (%s) while resolving route for %s'

    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      endpoint = endpoint_for(request)
      @app.call(env)
    ensure
      events[endpoint] << Event.new unless endpoint.nil?
    end

    private

    def events
      Sampler.configuration.event_processor.events
    end

    def find_routes
      # TODO: check if Rails.application.reload_routes!/reload! changes router
      @find_routes ||= Rails.application.routes.router.method(:find_routes)
    end

    def endpoint_for(request)
      # Getting first route here, ignoring X-Cascade
      route = find_routes.call(request).first
      # route is an Array [match_data, path_parameters, route] if found
      # TODO: what should we do for not found routes?
      route.nil? ? 'not#found' : route.last.path.spec.to_s
    rescue => e
      Sampler.configuration.logger.warn(format(RESOLVE_ERROR, e, request.url))
      nil
    end
  end
end
