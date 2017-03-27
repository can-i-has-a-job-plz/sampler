# frozen_string_literal: true

describe Sampler::Processor do
  context '#process' do
    let(:invalid_events) do
      [create(:event, params: nil), create(:event, request_body: nil)]
    end
    let(:valid_events) do
      [*create_list(:event, 3, endpoint: '/endpoint'),
       *create_list(:event, 3),
       *create_list(:event, 3, endpoint: '/another_endpoint')]
    end
    let!(:events) { (valid_events + invalid_events).shuffle }
    subject(:action) { -> { described_class.new.process } }
    before do
      Sampler.configuration.events # Clear
      events.each { |e| Sampler.configuration.storage << e }
    end

    shared_examples 'saving events' do
      it 'should save proper events' do
        should change(Sampler::Sample, :count).by(saved_events.size)
      end

      it 'should return saved samples count' do
        expect(described_class.new.process).to equal(saved_count)
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
          saved_events.map(&:to_h).map(&:stringify_keys).map do |e|
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

    # TODO: test all combinations

    context 'when max_per_endpoint nil' do
      before { Sampler.configuration.max_per_endpoint = nil }
      let(:saved_events) { valid_events }
      let(:saved_count) { saved_events.count }
      include_examples 'saving events'
    end

    context 'when max_per_endpoint is set' do
      before { Sampler.configuration.max_per_endpoint = 2 }
      let(:saved_events) { valid_events[1..-4] + valid_events[-2..-1] }
      let(:saved_count) { valid_events.count }
      include_examples 'saving events'
    end

    context 'when max_per_interval is set' do
      before { Sampler.configuration.max_per_interval = 5 }
      let(:events) do
        [*valid_events[0..3], *invalid_events, *valid_events[4..-1]]
      end
      let(:saved_events) { valid_events[0..4] }
      let(:saved_count) { saved_events.count }
      include_examples 'saving events'
    end

    context 'when retention_period is set' do
      before do
        Sampler.configuration.events # Clear
        Sampler.configuration.retention_period = 600
      end
      let!(:old_samples) { create_list(:sample, 5, created_at: 601.second.ago) }
      let(:old_ids) { old_samples.map(&:id) }
      let!(:new_samples) { create_list(:sample, 3) }

      it 'should delete proper number of samples' do
        should change(Sampler::Sample, :count).by(-old_samples.size)
      end
      it 'should delete proper samples' do
        should change { Sampler::Sample.where(id: old_ids).count }.to(0)
      end
    end
  end
end
