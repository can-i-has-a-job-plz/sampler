# frozen_string_literal: true
describe Sampler::Event do
  it { should respond_to(:endpoint) }
  it { should respond_to(:request) }
  it { should respond_to(:url) }
  it { should respond_to(:method) }
  it { should respond_to(:params) }
  it { should respond_to(:start) }
  it { should respond_to(:request_body) }
  it { should respond_to(:finish) }
  it { should respond_to(:response) }
  it { should respond_to(:response_body) }

  context '#duration' do
    let(:event) do
      e = described_class.new
      e.start = Time.at(1.day).in_time_zone("Nuku'alofa")
      e.finish = e.start + rand
      e
    end
    it 'should return difference between start and finish' do
      expect(event.duration).to eq(event.start - event.finish)
    end
  end

  context '#tags' do
    let(:event) { subject }
    let(:tags) { Sampler.configuration.tags }
    let(:logger) { Sampler.configuration.logger }
    before do
      3.times do |n|
        Sampler.configuration.tag_with 'should_raise', ->(_e) { raise 'oops' }
        Sampler.configuration.tag_with "tag#{n}", ->(_e) { n != 1 }
      end
    end
    it 'should call every filter_set with self' do
      tags.each_value { |fs| expect(fs).to receive(:call).with(event) }
      event.tags
    end
    it 'should return proper tags' do
      expect(event.tags).to match_array(%w(tag0 tag2))
    end
    it 'should log a warning if setting tag raised' do
      message = format(Sampler::Event::TAG_SETTING_ERROR, 'RuntimeError',
                       'oops', '"should_raise"')
      expect(logger).to receive(:warn).with(message)
      event.tags
    end
  end
end
