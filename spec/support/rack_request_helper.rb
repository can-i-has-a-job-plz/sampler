# frozen_string_literal: true

require 'rack/test'

module RackRequestHelper # :nodoc:
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Sampler::Middleware
      run SamplerApp.new
    end.to_app
  end

  class SamplerApp # :nodoc:
    def call(env)
      response(env)
    end

    private

    def response(env)
      [201, { 'Header' => 'Value' }, env['rack.input'].read]
    end
  end
end

RSpec.configure do |config|
  # TODO: remove when Style/MixinGrouping false positives will be fixed, likely
  # rubocop version next to 0.48.0
  # rubocop:disable Style/MixinGrouping
  config.include RackRequestHelper, type: :rack_request
  # rubocop:enable Style/MixinGrouping
end
