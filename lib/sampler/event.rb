# frozen_string_literal: true

module Sampler
  Event = Struct.new(:endpoint, :url, :request_method, :params, :request_body,
                     :created_at, :response_body, :updated_at, :tags)

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
      self.tags = []
      freeze
      Sampler.configuration.storage << self
    end

    def to_h
      tag_self unless tags.frozen?
      super
    end

    private

    def tag_self
      Sampler.configuration.tags.each_pair do |name, filter|
        begin
          tags << name if filter.call(self)
        rescue => e
          Sampler.logger.warn("Got #{e.class} (#{e}) while trying to set " \
                              "tag #{name.inspect} on #{self}")
        end
      end
      tags.freeze
    end
  end
end
