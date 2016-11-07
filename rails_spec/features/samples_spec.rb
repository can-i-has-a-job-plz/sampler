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
    let(:samples) { Sample.where(endpoint: '/endpoint1') }
    let(:sample) { samples.second }
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
    context 'Mass deletion' do
      let(:for_delete) do
        Sample.where(endpoint: '/endpoint1').pluck(:id).values_at(0, 1)
      end
      subject(:action) do
        lambda do
          for_delete.each { |id| check("samples[#{id}][id]") }
          click_on('Delete samples')
        end
      end
      it 'should delete proper number of samples' do
        should change(Sample, :count).by(-2)
      end
      it 'should delete proper samples' do
        should change { Sample.where(id: for_delete).count }.from(2).to(0)
      end
    end
    context 'Tag filtering' do
      before do
        samples.first.update(tags: ['tag1'])
        samples.last.update(tags: ['tag2'])
        fill_in(:tags, with: 'tag1, tag2')
        click_on('Filter samples')
      end
      it 'should show only matching samples' do
        should have_xpath('//tbody/tr', count: 2)
        should have_xpath("//tbody/tr[@id='sample#{samples.first.id}']")
        should have_xpath("//tbody/tr[@id='sample#{samples.last.id}']")
      end
    end
  end
end
