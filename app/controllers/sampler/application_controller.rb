# frozen_string_literal: true

module Sampler
  class ApplicationController < ActionController::Base # :nodoc:
    protect_from_forgery with: :exception
  end
end
