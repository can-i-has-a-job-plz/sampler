# frozen_string_literal: true
describe Sampler::Event do
  it { should respond_to(:endpoint) }
  it { should respond_to(:request) }
  it { should respond_to(:url) }
  it { should respond_to(:method) }
  it { should respond_to(:params) }
  it { should respond_to(:start) }
end
