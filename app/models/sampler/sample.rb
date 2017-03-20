# frozen_string_literal: true

module Sampler
  class Sample < ApplicationRecord # :nodoc:
    validates :endpoint, :url, :request_method, presence: true
    validates :params, :request_body, :response_body, :tags,
              exclusion: { in: [nil], message: 'cannot be nil' }
  end
end
