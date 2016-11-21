# frozen_string_literal: true
feature 'samples/index' do
  subject { page }
  before do
    create_list(:sample, 3, endpoint: '/endpoint1')
    create_list(:sample, 2, endpoint: '/endpoint2')
  end
  describe 'when no endpoint in params' do
    before { visit samples_path }
    it { should have_table('grouped_samples') }
    it 'should have all endpoint groups rendered' do
      expect(page).to have_xpath('//tbody/tr/td/a[text()="/endpoint1"]')
      expect(page).to have_xpath('//tbody/tr/td/a[text()="/endpoint2"]')
    end
  end
  describe 'when there is endpoint in params' do
    let(:endpoint) { '/endpoint1' }
    before { visit samples_path(endpoint: endpoint, method: :get) }
    it { should have_table('samples') }
    it 'should have proper endpoint rendered' do
      path = "//h2[text()='Samples for endpoint #{endpoint}, method: get']"
      should have_xpath(path)
    end
  end
end
