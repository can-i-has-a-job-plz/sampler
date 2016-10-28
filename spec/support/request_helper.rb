# frozen_string_literal: true
require 'rack/test'

module RequestHelper # :nodoc:
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Sampler::Middleware
      run SamplerApp.new
    end.to_app
  end

  class SamplerApp # :nodoc:
    def call(_env)
      Rack::Response.new('Whatever')
    end
  end
end

RSpec.configure do |config|
  config.include RequestHelper, type: :request
end
