# frozen_string_literal: true
require 'rails/generators/active_record/model/model_generator'

module ActiveRecord
  module Generators
    # @private
    # We can use simple `copy_file` here, but using ModelGenerator allows us
    #   not to bother with ApplicationRecord creation and such + in theory
    #   makes generator compatible with rails < 5
    class SampleModelGenerator < ActiveRecord::Generators::ModelGenerator
      VALIDATION_STRING = '  validates :%s, presence: true'
      source_root File.join(ActiveRecord::Generators::Base.base_root,
                            'active_record', 'model', 'templates')
      remove_class_option :timestamps, :migration

      # TODO: check if other DBs can handle arrays
      # TODO: try `params: [:json]` on MySQL & SQLite
      # TODO: max size for bodies?
      ATTRIBUTES = { endpoint: [:string, 'index'],
                     url: [:string],
                     method: [:string], # TODO: make me enum
                     params: [:jsonb],
                     request_body: [:text],
                     response_body: [:text],
                     tags: [:string, nil, array: true, default: []] }.freeze

      def initialize(*args)
        super
        self.options = options.merge(timestamps: true, migration: true)
      end

      def add_attributes_to_model
        model_file_name = File.join('app/models', class_path, "#{file_name}.rb")
        validations = attributes_names.map { |a| format(VALIDATION_STRING, a) }
        validations = validations.join("\n") + "\n"
        inject_into_class model_file_name, class_name, validations
      end

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
