# frozen_string_literal: true
describe Sampler::Railtie do
  it 'should eager_load Sampler' do
    expect(Rails.configuration.eager_load_namespaces).to include(Sampler)
  end
  it 'should install Sampler middleware' do
    expect(Rails.application.middleware).to include(Sampler::Middleware)
  end

  context 'generators' do
    let(:expected) { %w(install sample_model).map { |g| "sampler:#{g}" } }
    subject(:current) do
      Rails::Generators.subclasses.map(&:namespace).grep(/^sampler:/)
    end
    it 'should register all expected generators' do
      should match_array(expected)
    end
  end
end
