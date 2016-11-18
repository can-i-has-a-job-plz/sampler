# frozen_string_literal: true
module Sampler
  Event = Struct.new(:endpoint, :request, :url, :method, :params, :request_body,
                     :start, :finish, :response, :response_body)

  class Event # :nodoc:
    TAG_SETTING_ERROR = 'Got %s (%s) while trying to set tag %s on the event'

    def duration
      @duration ||= start - finish
    end

    def tags
      # FIXME: handle key deletion during tagging
      @tags ||= Sampler.configuration.tags.keys.select { |k| tag_with?(k) }
    end

    private

    def tag_with?(tag)
      Sampler.configuration.tags.fetch(tag).call(self)
    rescue => e
      # TODO: we want to show some useful info about event itself
      message = format(TAG_SETTING_ERROR, e.class, e, tag.inspect)
      Sampler.configuration.logger.warn(message)
      nil
    end
  end
end
