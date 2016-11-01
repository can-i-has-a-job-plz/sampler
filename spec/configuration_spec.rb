# frozen_string_literal: true
describe Sampler::Configuration do
  context '#probe_class' do
    it { should respond_to(:probe_class) }
    it { should respond_to(:probe_class=) }
    it 'should be nil after initialization' do
      expect(subject.probe_class).to be_nil
    end
  end
end
