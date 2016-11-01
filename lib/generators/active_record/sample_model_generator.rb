# frozen_string_literal: true
require 'rails/generators/active_record/model/model_generator'

module ActiveRecord
  module Generators
    # @private
    class SampleModelGenerator < ActiveRecord::Generators::ModelGenerator
      # We can use simple `copy_file` here, but using ModelGenerator allows us
      #   not to bother with ApplicationRecord creation and such + in theory
      #   makes generator compatible with rails < 5
      source_root File.join(ActiveRecord::Generators::Base.base_root,
                            'active_record', 'model', 'templates')
      # TODO: remove class_options, hardcode `timestamps: true`
      # TODO: check if other DBs can handle arrays
      # TODO: try `params: [:json]` on MySQL & SQLite
      # TODO: check params contents, maybe we should add controller/action
      # TODO: we want to have attributes in model file
      # TODO: max size for bodies?
      # TODO: indices: endpoint, what else?
      ATTRIBUTES = { endpoint: [:string],
                     url: [:string],
                     method: [:string], # TODO: make me enum
                     params: [:jsonb],
                     request_body: [:text],
                     response_body: [:text],
                     tags: [:string, nil, array: true, default: []] }.freeze

      private

      def attributes
        ATTRIBUTES.map do |name, opts|
          (opts[2] ||= {})[:null] = false
          Rails::Generators::GeneratedAttribute.new(name, *opts)
        end
      end
    end
  end
end
