# frozen_string_literal: true

describe Sampler::Railtie do
  it 'should eager_load Sampler' do
    expect(Rails.configuration.eager_load_namespaces).to include(Sampler)
  end
  it 'should install Sampler middleware' do
    expect(Rails.application.middleware).to include(Sampler::Middleware)
  end
end
