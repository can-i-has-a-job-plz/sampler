# frozen_string_literal: true

module Sampler
  Event = Struct.new(:endpoint, :url, :request_method, :params, :request_body,
                     :created_at, :response_body, :updated_at)

  class Event # :nodoc:
    # TODO: check input classes/duck_type?

    attr_reader :request, :response

    def initialize(endpoint, request)
      super(endpoint.freeze, request.url.freeze, request.request_method.freeze,
            request.params.freeze, request.body.read.freeze)
      request.body.rewind
      self.created_at = Time.now.utc
      @request = request
    end

    def finalize(resp)
      # TODO: warn on multiple finalization calls
      self.updated_at = Time.now.utc
      return (@response = resp) if resp.is_a?(Exception)
      # TODO: use Rack::BodyProxy.new for updated_at?
      @response = ActionDispatch::Response.new(*resp)
      self.response_body = response.body.freeze
      resp
    ensure
      freeze
    end
  end
end
