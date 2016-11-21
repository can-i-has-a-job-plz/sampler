# frozen_string_literal: true
describe 'samples/grouped_index' do
  subject { rendered }
  let(:page) { Capybara.string(rendered) }
  let(:samples) { Sample.group(:endpoint, :method).count }
  before do
    create_list(:sample, 3, endpoint: '/endpoint1')
    create_list(:sample, 2, endpoint: '/endpoint2', method: 'post')
    assign(:samples, samples)
    render
  end

  it { should have_table('grouped_samples') }
  it 'should have proper rows count' do
    should have_css('table > tbody > tr', count: samples.count)
  end
  it 'should have row for each endpoint' do
    samples.each do |sample, _count|
      endpoint, _method = sample
      should have_xpath('//tbody/tr/td[1]', text: endpoint)
    end
  end
  it 'should have link to endpoint samples index' do
    samples.each do |sample, _count|
      endpoint, method = sample
      node = page.find('//tbody/tr/td[1]', text: endpoint)
      href = samples_path(endpoint: endpoint, method: method)
      expect(node).to have_link(endpoint, href: href)
    end
  end
  it 'should have proper method for each endpoint' do
    samples.each do |sample, _count|
      endpoint, method = sample
      node = page.find('//tbody/tr/td[1]', text: endpoint)
      expect(node).to have_xpath("following-sibling::td[1][text()='#{method}']")
    end
  end
  it 'should have proper sample counts for each endpoint' do
    samples.each do |sample, count|
      endpoint, _method = sample
      node = page.find('//tbody/tr/td[1]', text: endpoint)
      expect(node).to have_xpath("following-sibling::td[2][text()='#{count}']")
    end
  end
end
