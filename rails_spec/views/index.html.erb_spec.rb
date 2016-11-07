# frozen_string_literal: true
describe 'samples/index' do
  subject { rendered }
  let(:endpoint) { '/endpoint1' }
  let(:page) { Capybara.string(rendered) }
  let(:samples) { Sample.where(endpoint: endpoint) }
  before do
    create_list(:sample, 3, endpoint: endpoint)
    assign(:samples, samples)
    assign(:endpoint, endpoint)
    render
  end

  it { should have_table('samples') }

  it 'should have proper heading' do
    should have_xpath("//h2[text()='Samples for endpoint #{endpoint}']")
  end
  it 'should have proper number of rows' do
    should have_xpath('//tbody/tr', count: 3)
  end
  it 'should have row for each sample' do
    samples.each { |s| should have_xpath("//tbody/tr[@id='sample#{s.id}']") }
  end
end
