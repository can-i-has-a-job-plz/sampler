# frozen_string_literal: true

module Sampler
  class ApplicationRecord < ActiveRecord::Base # :nodoc:
    self.abstract_class = true
  end
end
