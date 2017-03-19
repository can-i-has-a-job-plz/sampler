# frozen_string_literal: true

describe Sampler do
  it 'has a version number' do
    expect(Sampler::VERSION).not_to be nil
  end

  it { should delegate_method(:start).to(:configuration) }
  it { should delegate_method(:stop).to(:configuration) }
  it { should delegate_method(:running?).to(:configuration) }
  it { should delegate_method(:sampled?).to(:configuration) }

  context '.configuration' do
    subject(:configuration) { Sampler.configuration }
    it 'should be Sampler::Configuration instance' do
      should be_instance_of(Sampler::Configuration)
    end
    it 'should be persistent' do
      expect { Sampler.configuration }.not_to(change { Sampler.configuration })
    end
  end

  context '.configure' do
    subject(:configuration) { Sampler.configuration }
    it 'should invoke the block and yield configuration' do
      should receive(:nil?)
      Sampler.configure(&:nil?)
    end
  end
end
