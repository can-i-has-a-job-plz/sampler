# frozen_string_literal: true

describe 'sampler/samples/_sample' do
  subject { rendered }
  let(:page) { Capybara.string(rendered) }
  let(:sample) { create(:sample) }
  before { render(partial: 'sample', locals: { sample: sample }) }
  it 'has id sampleN' do
    should have_css("tr#sample#{sample.id}")
  end
  it 'has 6 columns' do
    should have_css('tr > td', count: 6)
  end

  it 'has link to sample page in first column' do
    expect(page.find(:css, 'td:nth-child(1)'))
      .to have_link("Sample #{sample.id}", href: sampler.sample_path(sample))
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
  it 'has link to delete sample in fifth column' do
    expect(page.find(:css, 'td:nth-child(5)'))
      .to have_link('Delete sample', href: sampler.sample_path(sample))
  end
  it 'has checkbox for mass deletion in sixth column' do
    opts = { type: 'checkbox', with: 1, checked: false }
    expect(page.find(:css, 'td:nth-child(6)'))
      .to have_field("samples[#{sample.id}][id]", opts)
  end
end
