# frozen_string_literal: true

require_dependency 'sampler/application_controller'

module Sampler
  class SamplesController < ApplicationController # :nodoc:
    def index
      unless params.key?(:endpoint) && params.key?(:request_method)
        return grouped_index
      end
      @endpoint = params[:endpoint]
      @request_method = params[:request_method]
      @samples = Sample.order(:id)
                       .where(endpoint: @endpoint,
                              request_method: @request_method)
    end

    def destroy_all
      for_delete = if params[:endpoint] && params[:request_method]
                     Sample.where(endpoint: params[:endpoint],
                                  request_method: params[:request_method])
                   else
                     Sample
                   end
      for_delete.delete_all
    end

    private

    def grouped_index
      @samples = all_routes.merge(samples)
                           .to_a
                           .map { |(ep, m), cnt| [ep, m, cnt, sampled?(ep)] }
                           .sort { |x, y| compare_samples(x, y) }
      render :grouped_index
    end

    def compare_samples(x, y)
      # [endpoint, request_method, count, sampled?]
      # Sort by count and sampled?
      if x[2] != y[2]
        x[2] < y[2] ? 1 : -1
      elsif x[3] != y[3]
        x[3] ? -1 : 1
      else 0
      end
    end

    def sampled?(endpoint)
      Sampler.sampled?(endpoint)
    end

    def all_routes
      RoutesInspector.new.routes.map { |r| [[r[:path], r[:verb]], 0] }.to_h
    end

    def samples
      Sample.group(:endpoint, :request_method).count
    end
  end
end