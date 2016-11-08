# frozen_string_literal: true
class SamplesController < ApplicationController # :nodoc:
  def index
    @samples = klass.group(:endpoint).count
    render :grouped_index
  end

  private

  def klass
    Sampler.configuration.probe_class
  end
end
