# frozen_string_literal: true

module Sampler
  # Rack middleware for request sampling
  class Middleware
    NOT_FOUND_ENDPOINT = 'not#found'
    RESOLVE_ERROR_ENDPOINT = 'resolve#error'

    def initialize(app)
      @app = app
    end

    def call(env)
      event = event_from(env)
      return @app.call(env) if event.nil?
      response = @app.call(env)
      event.finalize(response.dup)
      response
    rescue Exception => e # rubocop:disable Lint/RescueException
      event&.finalize(e)
      raise
    end

    private

    def event_from(env)
      return unless Sampler.running?
      request = ActionDispatch::Request.new(env.dup)
      endpoint = endpoint_for(request, Rails.application, '')
      return unless Sampler.sampled?(endpoint)
      Event.new(endpoint, request)
    end

    def find_routes(app)
      # TODO: check if Rails.application.reload_routes!/reload! changes router
      (@engines ||= {})[app] ||= app.routes.router.method(:find_routes)
    end

    def endpoint_for(request, app, base_path)
      # Getting first route here, ignoring X-Cascade
      match, _parameters, route = find_routes(app).call(request).first

      return NOT_FOUND_ENDPOINT if route.nil?

      if route.app.app.respond_to?(:routes)
        request.path_info = match.post_match
        return endpoint_for(request, route.app.app, "#{base_path}#{match}")
      end

      "#{base_path}#{route.path.spec}"
    rescue => _e
      RESOLVE_ERROR_ENDPOINT
    end
  end
end
