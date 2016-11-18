# frozen_string_literal: true
module Sampler
  # Rack middleware for request sampling
  class Middleware
    RESOLVE_ERROR = 'Got error (%s) while resolving route for %s'

    def initialize(app)
      @app = app
    end

    def call(env)
      event = event_from_request(env)
      @app.call(env)
    ensure
      events[event.endpoint] << event unless event.nil?
    end

    private

    def events
      Sampler.configuration.event_processor.events
    end

    # rubocop:disable Metrics/AbcSize
    def event_from_request(env)
      request = ActionDispatch::Request.new(env.dup)
      endpoint = endpoint_for(request)
      return if endpoint.nil?
      # TODO: do we want values from request or from env?
      # TODO: is url with query string ok for us?
      # NB! request should not be frozen since manipulations with it
      #   (from tagging, for example) can modify it
      event = Event.new(endpoint, request, request.url.freeze,
                        request.method.freeze, request.params.freeze,
                        request.body.read)
      request.body.rewind
      event.start = Time.now.utc
      event
    end
    # rubocop:enable Metrics/AbcSize

    def find_routes
      # TODO: check if Rails.application.reload_routes!/reload! changes router
      @find_routes ||= Rails.application.routes.router.method(:find_routes)
    end

    def endpoint_for(request)
      # TODO: config option to strip format?
      # TODO: check scope, namespace, nested routes, various wildcards and
      #   optional parts. What else?
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
