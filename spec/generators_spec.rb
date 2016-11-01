# frozen_string_literal: true
describe Sampler::Generators::InstallGenerator, type: :generator do
  let(:generate_count) { 1 }
  before { allow(generator).to receive(:run_ruby_script).with(any_args) }

  context 'when no arguments are passed' do
    include_examples 'should run generator', 'sample_model', 'Sample'
  end

  context 'when one argument is passed' do
    let(:args) { ['model_name'] }
    include_examples 'should run generator', 'sample_model', 'model_name'
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
