# frozen_string_literal: true
class SamplesController < ApplicationController # :nodoc:
  def index
    return grouped_index unless params.key?(:endpoint)
    @endpoint = params[:endpoint]
    @samples = klass.where(endpoint: @endpoint)
  end

  def show
    @sample = klass.find(params[:id])
  end

  def destroy
    klass.find(params[:id]).destroy
    flash[:success] = "Sample #{params[:id]} was deleted"
    redirect_to action: :index
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
