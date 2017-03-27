# frozen_string_literal: true

describe 'sampler/samples/index' do
  subject { rendered }
  let(:endpoint) { '/endpoint1' }
  let(:request_method) { 'MKCALENDAR' }
  let(:page) { Capybara.string(rendered) }
  let(:samples) do
    Sampler::Sample.where(endpoint: endpoint, request_method: request_method)
  end
  before do
    create_list(:sample, 3, endpoint: endpoint, request_method: request_method)
    assign(:samples, samples)
    assign(:endpoint, endpoint)
    assign(:request_method, request_method)
    render
  end

  it { should have_table('samples') }

  it 'should have proper heading' do
    should have_xpath("//h2[text()='Samples for endpoint #{endpoint}, " \
                      "request method: #{request_method}']")
  end
  it 'should have proper number of rows' do
    should have_xpath('//tbody/tr', count: 3)
  end
  it 'should have row for each sample' do
    samples.each { |s| should have_xpath("//tbody/tr[@id='sample#{s.id}']") }
  end
end
