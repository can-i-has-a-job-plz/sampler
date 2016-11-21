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

  context '.start' do
    it 'should call configuration.start' do
      expect(subject.configuration).to receive(:start)
      subject.start
    end
  end

  context '.stop' do
    it 'should call configuration.start' do
      # called once in after callback, so checking if called twice
      expect(subject.configuration).to receive(:stop).twice
      subject.stop
    end
  end

  context '.running?' do
    let(:value) { Object.new }
    it 'should return config.running' do
      expect(subject.configuration).to receive(:running).and_return(value)
      expect(Sampler.running?).to be(value)
    end
  end
end
