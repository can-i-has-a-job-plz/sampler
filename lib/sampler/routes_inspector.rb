# frozen_string_literal: true

module Sampler
  class RoutesInspector < ActionDispatch::Routing::RoutesInspector # :nodoc:
    def initialize
      @routes = Rails.application.routes.routes
      @engines = {}
    end

    def routes # rubocop:disable Metrics/AbcSize
      routes = collect_routes(@routes)
      routes.each do |route|
        next unless @engines.key?(route[:reqs])
        @engines[route[:reqs]].each do |engine_route|
          # TODO: handle nested engines
          engine_route[:path] = "#{route[:path]}#{engine_route[:path]}"
        end
      end
      routes.concat(*@engines.values)
      routes.reject { |r| @engines.key?(r[:reqs]) && r[:verb].blank? }
    end
  end
end
