# frozen_string_literal: true
module Sampler
  Event = Struct.new(:endpoint, :request, :url, :method, :params, :request_body,
                     :start, :finish)

  class Event # :nodoc:
    def duration
      @duration ||= start - finish
    end
  end
end
