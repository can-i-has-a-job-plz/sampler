# frozen_string_literal: true
require 'generators/sampler'

describe Sampler::Generators::InstallGenerator, type: :generator do
  let(:generate_count) { 3 }
  before { allow(generator).to receive(:run_ruby_script).with(any_args) }

  context 'when no arguments are passed' do
    include_examples 'should run generator', 'sample_model', 'Sample'
    include_examples 'should run generator', 'initializer', 'Sample'
  end

  context 'when one argument is passed' do
    let(:args) { ['model_name'] }
    include_examples 'should run generator', 'sample_model', 'model_name'
    include_examples 'should run generator', 'initializer', 'model_name'
  end

  it 'should not run other generators' do
    should receive(:run_ruby_script).exactly(generate_count).times
    generate!
  end
end

describe Sampler::Generators::SampleModelGenerator, type: :generator do
  context 'when no arguments are passed' do
    it 'should raise' do
      message = "No value provided for required arguments 'name'"
      error = Thor::RequiredArgumentMissingError
      expect { generate! }.to raise_error(error).with_message(message)
    end
  end

  context 'when one argument is passed' do
    let(:args) { ['model_name'] }
    let(:model_name) { generator.name.underscore }
    let(:migration_name) { model_name.pluralize }

    context 'when ORM is not set' do
      pending 'should do something'
    end
    context 'when ORM is set but not available' do
      pending 'should do something'
    end

    context 'when ORM is ActiveRecord' do
      let(:options) { { orm: :active_record } }
      include_examples 'should generate a model'
    end
  end
end

describe Sampler::Generators::InitializerGenerator, type: :generator do
  let(:template) { File.join(described_class.source_root, 'initializer.rb') }
  let(:target_path) do
    Rails.root.join('config', 'initializers', 'sampler.rb').to_path
  end

  it 'should create Sampler initializer' do
    expect(File).to receive(:open).with(target_path, 'wb')
    generate!
  end

  context 'initializer' do
    before { generate! }
    subject(:initalizer) { File.read(target_path) }
    it 'should contain Sampler.configure block' do
      should match(/\ASampler.configure do |config|$/)
      should match(/^end$/)
    end
    it 'should start Sampler' do
      should match(/^Sampler.start\s#.*/)
    end
    context 'if no arguments are passed' do
      it 'should use Sample as probe_class' do
        should match(/^  config.probe_class = Sample$/)
      end
    end
    context 'if argument is passed' do
      let(:args) { ['model_name'] }
      it 'should use passed model name as probe_class' do
        should match(/^  config.probe_class = ModelName$/)
      end
    end
  end
end
