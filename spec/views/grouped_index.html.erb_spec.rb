# frozen_string_literal: true

describe 'sampler/samples/grouped_index' do
  subject { rendered }
  let(:page) { Capybara.string(rendered) }
  let(:samples) do
    [['/endpoint1', 'GET', 0, true],
     ['/endpoint2', 'POST', 1, false],
     ['/endpoint3', 'PUT', 2, true]]
  end
  before do
    assign(:samples, samples)
    render
  end

  it { should have_table('grouped_samples') }

  it 'should have proper rows count' do
    should have_css('table > tbody > tr', count: samples.count)
  end

  it 'should have proper columns count' do
    expect(page.all(:xpath, '//tbody/tr[count(./td) = 5]').count)
      .to eql(samples.count)
  end

  it 'should have row for each endpoint' do
    expect(page.find_all(:xpath, '//tbody/tr/td[1]').map(&:text))
      .to(eql(samples.map { |s| s[0] }))
  end

  it 'should have index links to endpoint index for endpoints with samples' do
    samples[1..2].each do |endpoint, request_method, *|
      href = sampler.samples_path(endpoint: endpoint,
                                  request_method: request_method)
      expect(page.find('//tbody/tr/td', text: endpoint))
        .to have_link(endpoint, href: href)
    end
  end

  it 'should not have index links for endpoints without samples' do
    expect(page.find('//tbody/tr[1]/td[1]')).not_to have_link
  end

  it 'should have proper request methods' do
    expect(page.find_all(:xpath, '//tbody/tr/td[2]').map(&:text))
      .to(eql(samples.map { |s| s[1] }))
  end

  it 'should have proper counts' do
    expect(page.find_all(:xpath, '//tbody/tr/td[3]').map(&:text))
      .to(eql(samples.map { |s| s[2].to_s }))
  end

  it 'should have proper sampled? value' do
    expect(page.find_all(:xpath, '//tbody/tr/td[4]').map(&:text))
      .to(eql(samples.map { |s| s[3].to_s }))
  end
end
