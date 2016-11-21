# frozen_string_literal: true
class SamplesController < ApplicationController # :nodoc:
  def index
    return grouped_index unless params.key?(:endpoint) && params.key?(:method)
    @endpoint = params[:endpoint]
    @method = params[:method]
    @samples = klass.where(endpoint: @endpoint, method: @method)
  end

  private

  def klass
    Sampler.configuration.probe_class
  end

  def grouped_index
    @samples = klass.group(:endpoint, :method).count
    render :grouped_index
  end
end
