# frozen_string_literal: true
feature 'samples/index' do
  subject { page }
  describe 'when no endpoint in params' do
    before { visit samples_path }
    it { should have_table('grouped_samples') }
  end
end
