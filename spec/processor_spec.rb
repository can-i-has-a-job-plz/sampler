# frozen_string_literal: true

describe Sampler::Processor do
  context '#process' do
    let(:invalid_events) do
      [create(:event, params: nil), create(:event, request_body: nil)]
    end
    let(:valid_events) { create_list(:event, 3) }
    let!(:events) { (valid_events + invalid_events).shuffle }
    subject(:action) { -> { described_class.new.process } }
    before do
      Sampler.configuration.events # Clear
      events.each { |e| Sampler.configuration.storage << e }
    end

    it 'should save only valid events' do
      should change(Sampler::Sample, :count).by(3)
    end

    it 'should return saved samples count' do
      expect(described_class.new.process).to equal(3)
    end

    context 'saved Samples' do
      before { action.call }
      # PostgreSQL and Ruby has different time precision, so let's truncate
      # timestamps to ms, that's enough
      let(:sample_attrs) do
        Sampler::Sample.all.map { |s| s.attributes.except('id') }.map do |s|
          %w(created_at updated_at).each { |k| s[k] = format('%.3f', s[k]) }
          s
        end
      end
      let(:events_attrs) do
        valid_events.map(&:to_h).map(&:stringify_keys).map do |e|
          %w(created_at updated_at).each { |k| e[k] = format('%.3f', e[k]) }
          e
        end
      end

      it 'should have proper attributes' do
        expect(sample_attrs).to match_array(events_attrs)
      end
    end

    it 'should warn about all invalid events' do
      invalid_events.each do |e|
        missing_field = (e.params ? 'request_body' : 'params').humanize
        msg = "Got invalid sample from #{e}, " +
              %(errors: ["#{missing_field} cannot be nil"])
        expect(Sampler.logger).to receive(:warn).with(msg)
      end
      action.call
    end
  end
end
