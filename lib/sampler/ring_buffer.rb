# frozen_string_literal: true
require 'concurrent/configuration'
require 'concurrent/channel/buffer'

module Sampler
  class RingBuffer < Concurrent::Channel::Buffer::Sliding # :nodoc:
    alias << offer

    def shift(n)
      a = []
      n.times do
        v = poll
        break if v.equal?(Concurrent::NULL)
        a << v
      end
      a
    end
  end
end
