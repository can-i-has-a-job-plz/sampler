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
end
