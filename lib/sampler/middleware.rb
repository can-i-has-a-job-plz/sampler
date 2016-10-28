# frozen_string_literal: true
module Sampler
  # Rack middleware for request sampling
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    end
  end
end
