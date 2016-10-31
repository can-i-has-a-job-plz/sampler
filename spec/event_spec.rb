# frozen_string_literal: true
describe Sampler::Event, type: :request do
  PAYLOAD_KEYS = %i(endpoint url method params request request_body response
                    response_body).freeze

  subject(:event) do
    Sampler::Event.new('name', Time.now.utc, Time.now.utc + 1, 'unique_id',
                       payload)
  end

  shared_examples 'should have getter for key' do |key|
    context "##{key}" do
      let(:payload) { { key => Object.new } }
      it 'should return value from payload' do
        expect(event.send(key)).to be(payload[key])
      end
    end
  end

  PAYLOAD_KEYS.each { |k| include_examples 'should have getter for key', k }

  shared_examples 'somelisted?' do
    let(:payload) { {} }
    let(:result) { Object.new }
    let(:list) { Sampler.configuration.send(somelist) }
    before { allow(list).to receive(:match).and_return(result) }

    it 'should match event against configured list' do
      expect(list).to receive(:match).with(event)
      event.send("#{somelist}ed?")
    end
    it 'should return match result' do
      expect(event.send("#{somelist}ed?")).to be(result)
    end
  end

  context 'whitelisted?' do
    let(:somelist) { :whitelist }
    include_examples 'somelisted?'
  end
  context 'blacklisted?' do
    let(:somelist) { :blacklist }
    include_examples 'somelisted?'
  end
end