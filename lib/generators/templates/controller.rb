# frozen_string_literal: true
class SamplesController < ApplicationController # :nodoc:
  def index
    return grouped_index unless params.key?(:endpoint)
    @endpoint = params[:endpoint]
    @samples = klass.where(endpoint: @endpoint)
  end

  private

  def klass
    Sampler.configuration.probe_class
  end

  def grouped_index
    @samples = klass.group(:endpoint).count
    render :grouped_index
  end
end
