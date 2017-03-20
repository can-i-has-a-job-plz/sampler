# frozen_string_literal: true

module Sampler
  # Rack middleware for request sampling
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      event = Event.new(ActionDispatch::Request.new(env.dup))
      response = @app.call(env)
      event.finalize(response.dup)
      response
    rescue Exception => e # rubocop:disable Lint/RescueException
      event.finalize(e)
      raise
    end
  end
end
