# frozen_string_literal: true
module Sampler
  Event = Struct.new(:endpoint, :request, :url, :method, :params, :request_body,
                     :start)
end
