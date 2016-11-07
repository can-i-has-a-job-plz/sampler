# frozen_string_literal: true
require 'rails/generators/named_base'

module Sampler
  module Generators
    # @private
    class ControllerGenerator < Rails::Generators::NamedBase
      # FIXME: right now controller_name is not taken into account in
      #   templates/routes
      argument :name, type: :string, default: 'Samples'
      source_root File.expand_path('../../templates', __FILE__)
      desc 'This generator creates Sampler controller and views files'

      check_class_collision suffix: 'Controller'

      def copy_controller
        copy_file 'controller.rb', File.join('app', 'controllers',
                                             "#{file_name}_controller.rb")
      end

      def copy_views
        directory 'views', File.join('app', 'views', file_name)
      end

      def create_routes
        route 'resources :samples, only: [:index, :show]'
      end
    end
  end
end
