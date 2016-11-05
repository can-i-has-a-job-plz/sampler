# frozen_string_literal: true
require 'rails/generators/active_record/model/model_generator'

module ActiveRecord
  module Generators
    # @private
    class SampleModelGenerator < ActiveRecord::Generators::ModelGenerator
      VALIDATION_STRING = '  validates :%s, presence: true'
      source_root File.join(ActiveRecord::Generators::Base.base_root,
                            'active_record', 'model', 'templates')
      remove_class_option :timestamps, :migration, :parent, :indexes,
                          :primary_key_type

      # TODO: check if other DBs can handle arrays
      # TODO: check if other DBs can handle :json datatype
      # TODO: max size for bodies?
      ATTRIBUTES = { endpoint: [:string, nil, index: true],
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
        model_file_name = File.join('app', 'models', "#{file_name}.rb")
        validations = %i(endpoint url method).map do |a|
          format(VALIDATION_STRING, a)
        end
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
