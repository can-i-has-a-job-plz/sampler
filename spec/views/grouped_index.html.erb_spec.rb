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
    expect(page.all(:xpath, '//tbody/tr[count(./td) = 4]').count)
      .to eql(samples.count)
  end

  it 'should have row for each endpoint' do
    expect(page.find_all(:xpath, '//tbody/tr/td[1]').map(&:text))
      .to(eql(samples.map { |s| s[0] }))
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
