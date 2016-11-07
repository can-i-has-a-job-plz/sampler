# frozen_string_literal: true
describe 'samples/show' do
  subject { rendered }
  let(:sample) { create(:sample) }
  before do
    assign(:sample, sample)
    render
  end

  it 'should have proper heading' do
    should have_xpath("//h2[text()='Sample #{sample.id}']")
  end
  it 'should show sample.url' do
    should have_text("Url: #{sample.url}")
  end
  it 'should show sample.method' do
    should have_text("Method: #{sample.method}")
  end
  it 'should show sample.tags' do
    should have_text("Tags: #{sample.tags}")
  end
  it 'should show sample.params' do
    should have_text("Params: #{sample.params}")
  end
  it 'should show sample.request_body' do
    should have_css('pre', text: sample.request_body)
  end
  it 'should show sample.response_body' do
    should have_css('pre', text: sample.response_body)
  end
end
