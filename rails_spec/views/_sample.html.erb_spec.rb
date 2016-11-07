# frozen_string_literal: true
describe 'samples/_sample' do
  subject { rendered }
  let(:sample) { create(:sample) }
  let(:page) { Capybara.string(rendered) }
  before { render(partial: 'sample', locals: { sample: sample }) }

  it 'has id sampleN' do
    should have_css("tr#sample#{sample.id}")
  end
  it 'has 6 columns' do
    should have_css('tr > td', count: 6)
  end
  it 'has link to sample page in first column' do
    node = page.find(:css, 'td:nth-child(1)')
    expect(node).to have_link("Sample #{sample.id}", href: sample_path(sample))
  end
  it 'has sample.url in second column' do
    should have_css('td:nth-child(2)', text: sample.url)
  end
  it 'has sample.method in third column' do
    should have_css('td:nth-child(3)', text: sample.method)
  end
  it 'has sample.params in fourth column' do
    should have_css('td:nth-child(4)', text: sample.params)
  end
  it 'has sample.tags in fifth column' do
    should have_css('td:nth-child(5)', text: sample.tags)
  end
  it 'has link to delete sample in sixth column' do
    node = page.find(:css, 'td:nth-child(6)')
    expect(node).to have_link('Delete sample', href: sample_path(sample))
  end
end
