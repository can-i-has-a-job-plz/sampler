# frozen_string_literal: true
require 'active_support/notifications'

module Sampler
  # Rack middleware for request sampling
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(_env)
      instrumenter.start('request.sampler', nil)
      @app.call(nil)
    ensure
      instrumenter.finish('request.sampler', nil)
    end

    private

    def instrumenter
      ActiveSupport::Notifications.instrumenter
    end
  end
end
