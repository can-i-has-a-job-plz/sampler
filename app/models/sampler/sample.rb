# frozen_string_literal: true

module Sampler
  class Sample < ActiveRecord::Base # :nodoc:
    validates :endpoint, :url, :request_method, presence: true
    validates :params, :request_body, :response_body, :tags,
              exclusion: { in: [nil], message: 'cannot be nil' }

    def self.with_tags(tags)
      return where("tags = '{}'") if tags.empty?
      where('tags && ARRAY[?]::varchar[]', tags)
    end
  end
end
