# frozen_string_literal: true

describe 'sampler/samples/_sample' do
  subject { rendered }
  let(:sample) { create(:sample) }
  before { render(partial: 'sample', locals: { sample: sample }) }
  it 'has id sampleN' do
    should have_css("tr#sample#{sample.id}")
  end
  it 'has 4 columns' do
    should have_css('tr > td', count: 4)
  end
  it 'has sample.id in first column' do
    should have_css('td:nth-child(1)', text: sample.id)
  end
  it 'has sample.url in second column' do
    should have_css('td:nth-child(2)', text: sample.url)
  end
  it 'has sample.params in third column' do
    should have_css('td:nth-child(3)', text: sample.params)
  end
  it 'has sample.tags in fourth column' do
    should have_css('td:nth-child(4)', text: sample.tags)
  end
end