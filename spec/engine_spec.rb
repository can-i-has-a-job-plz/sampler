# frozen_string_literal: true

describe Sampler::Engine do
  it 'should install Sampler middleware' do
    expect(Rails.application.middleware).to include(Sampler::Middleware)
  end
end
