# frozen_string_literal: true
describe Sampler::Railtie do
  it 'should eager_load Sampler' do
    expect(Rails.configuration.eager_load_namespaces).to include(Sampler)
  end

  context 'generators' do
    let(:expected) { %w(install sample_model).map { |g| "sampler:#{g}" } }
    subject(:current) { Rails::Generators.public_namespaces.grep(/^sampler:/) }
    it 'should register all expected generators' do
      should match_array(expected)
    end
  end
end
