# frozen_string_literal: true

require 'sampler/version'
require 'sampler/railtie'

# Just a namespace for all Sampler code
module Sampler
  autoload :Middleware, 'sampler/middleware'
end
