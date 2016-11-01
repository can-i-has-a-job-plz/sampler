# frozen_string_literal: true
describe Sampler do
  subject { Sampler }
  it 'has a version number' do
    expect(Sampler::VERSION).not_to be nil
  end

  context '.configuration' do
    subject(:configuration) { Sampler.configuration }
    it 'should be Sampler::Configuration instance' do
      should be_a(Sampler::Configuration)
    end
  end

  context '.configure' do
    subject(:configuration) { Sampler.configuration }
    it 'should invoke the block and yield configuration' do
      should receive(:attribute)
      Sampler.configure(&:attribute)
    end
  end
end
