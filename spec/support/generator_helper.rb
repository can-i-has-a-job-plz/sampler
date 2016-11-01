# frozen_string_literal: true
module GeneratorHelper # :nodoc:
  # TODO: silence/capture generators output
  require 'generators/sampler'

  # Configure AR to run migrations during model generation
  # FIXME: pass `migration: true, timestamps: true` in generator options
  # FIXME: we should set it somehow in migration itself
  Rails::Generators.options[:active_record] = { migration: true,
                                                timestamps: true }

  def generate!
    generator.invoke_all
  end

  def migrations
    Dir.glob(Rails.root.join('db', 'migrate', '[0-9]*_*.rb'))
       .map { |f| File.basename(f) }
       .grep(/\d+_create_#{migration_name}.rb$/)
  end

  def models
    Dir.glob(Rails.root.join('app', 'models', '*.rb'))
       .map { |f| File.basename(f) }
       .grep("#{model_name}.rb")
  end

  RSpec.shared_context 'generator setup' do
    let(:args) { [] }
    let(:options) { {} }

    subject(:generator) do
      described_class.new(args, options, destination_root: Rails.root)
    end

    before do
      FileUtils.rm_rf(Rails.root)
      FileUtils.mkdir_p(Rails.root)
    end

    after(:all) { FileUtils.rm_rf(Rails.root) }
  end

  RSpec.shared_examples 'should run generator' do |name, *args|
    it 'should run available generator' do
      class_name = "#{name.camelize}Generator"
      expect(Sampler::Generators.const_defined?(class_name)).to eq(true)
    end
    it "should run sampler:#{name} generator with args #{args}" do
      arg = ['bin/rails generate', "sampler:#{name}", args.join(' ')].join(' ')
      should receive(:run_ruby_script).with(arg, verbose: false)
      generate!
    end
  end

  RSpec.shared_examples 'should generate a model' do
    it 'should create a migration with proper name' do
      expect { generate! }.to change { migrations.count }.from(0).to(1)
    end
    pending 'should create a migration with proper content'
    it 'should create a model with proper name' do
      expect { generate! }.to change { models.count }.from(0).to(1)
    end
    pending 'should create a model with proper content'
  end
end

RSpec.configure do |config|
  config.include_context 'generator setup', type: :generator
  config.include GeneratorHelper, type: :generator
end
