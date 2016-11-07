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
    let(:sample) { Sample.where(endpoint: endpoint).second }
    before { visit samples_path(endpoint: endpoint) }
    it { should have_table('samples') }
    it 'should have proper endpoint rendered' do
      should have_xpath("//h2[text()='Samples for endpoint #{endpoint}']")
    end
    context 'Delete sample links' do
      let(:link) do
        page.find_link('Delete sample', href: sample_path(sample))
      end
      subject(:action) { -> { link.click } }
      it 'should delete sample' do
        should change(Sample, :count).by(-1)
      end
      it 'should delete proper sample' do
        should change { Sample.where(id: sample).count }.from(1).to(0)
      end
    end
  end
end
