# frozen_string_literal: true
require 'rails/generators/base'

module Sampler
  module Generators
    # @private
    class ControllerGenerator < Rails::Generators::Base
      argument :model_name, type: :string, default: 'Sample'
      source_root File.expand_path('../../templates', __FILE__)
      desc 'This generator creates Sampler controller file'

      def copy_controller
        copy_file 'controller.rb', 'app/controllers/samples_controller.rb'
      end

      def copy_views
        directory 'views', 'app/views/samples'
      end

      def create_routes
        route 'end'
        route '  post :update, on: :collection'
        route 'resources :samples, only: [:index, :show, :destroy] do'
      end
    end
  end
end
