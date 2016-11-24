# frozen_string_literal: true
describe Sampler::RingBuffer do
  let(:size) { 5 }
  subject(:ring_buffer) { described_class.new(size) }
  before { size.times { |n| ring_buffer << n } }
  context '#<<' do
    it 'should be alias to :offer' do
      expect(subject.method(:<<)).to be_eql(subject.method(:offer))
    end
  end

  context '#shift' do
    subject(:values) { ring_buffer.shift(size) }
    it 'should return array with values in proper order' do
      should eq((0..(size - 1)).to_a)
    end
    context 'when requested count is greater than available values' do
      subject(:values) { ring_buffer.shift(size + 1) }
      it 'should return available items' do
        should eq((0..(size - 1)).to_a)
      end
    end
    context 'when requested count is lesser than available values' do
      subject(:values) { ring_buffer.shift(size - 1) }
      it 'should return requested number of items' do
        should eq((0..(size - 2)).to_a)
      end
      it 'should retain other values' do
        expect { values }.to change(ring_buffer, :size).to(1)
      end
    end
  end
end
