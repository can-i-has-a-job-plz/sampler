# frozen_string_literal: true
describe 'retention' do
  subject(:action) do
    lambda do
      get '/whatever'
      Sampler::Notifications.executor.shutdown
      Sampler::Notifications.executor.wait_for_termination(0.01)
      Sampler::Notifications.executor = Concurrent::SingleThreadExecutor.new
    end
  end
  let!(:old_samples) do
    create_list(:sample, 3, created_at: Time.now.utc - 1,
                            updated_at: Time.now.utc)
  end
  let!(:new_samples) do
    create_list(:sample, 3, created_at: Time.now.utc,
                            updated_at: Time.at(1).utc)
  end
  before { Sampler.configuration.whitelist << '' }

  describe 'max_probes_per_hour' do
    context 'when nil' do
      before { Sampler.configuration.max_probes_per_hour = nil }
      it 'should not delete any samples' do
        should change(Sample, :count).by(1)
      end
    end
    context 'when not nil' do
      before do
        Sampler.configuration.max_probes_per_hour = new_samples.count + 1
      end
      it 'should delete old samples and add new one' do
        should change(Sample, :count).by(1 - old_samples.count)
      end
      it 'should delete proper samples' do
        should change { Sample.where(id: old_samples.map(&:id)).count }.to(0)
      end
    end
  end
end
