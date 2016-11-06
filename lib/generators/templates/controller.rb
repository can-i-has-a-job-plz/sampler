# frozen_string_literal: true
class SamplesController < ApplicationController # :nodoc:
  def index
    return grouped_index unless params.key?(:endpoint) && params.key?(:method)
    @endpoint = params[:endpoint]
    @method = params[:method]
    @samples = klass.where(endpoint: @endpoint, method: @method)
  end

  def show
    @sample = klass.find(params[:id])
  end

  def destroy
    klass.find(params[:id]).destroy
    flash[:success] = "Sample #{params[:id]} was deleted"
    redirect_to action: :index
  end

  def mass_destroy
    for_delete = params[:samples].select { |_k, v| v[:id] == '1' }.keys
    klass.where(id: for_delete).destroy_all
    flash[:success] = "Samples #{for_delete} was deleted"
    redirect_to action: :index
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
