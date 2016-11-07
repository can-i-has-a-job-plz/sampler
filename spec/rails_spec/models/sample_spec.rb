# frozen_string_literal: true
RSpec.describe Sample do
  %i(endpoint url method).each do |attr|
    context "##{attr}" do
      let(:attribute) { attr }
      it { should respond_to(attr) }
      it { should validate_presence_of(attr) }
    end
  end
  it 'should have default value [] for tags' do
    expect(subject.tags).to eq([])
  end

  context '#with_tags' do
    subject { Sample.with_tags(tags) }
    let!(:samples) do
      Array.new(5) { |n| create(:sample, tags: ["tag#{n + 1}", 'some tags']) }
    end
    let!(:without_tags) { create_list(:sample, 2, tags: []) }
    context' when no tags are given' do
      let(:tags) { [] }
      it 'should return samples without tags' do
        without_tags.each { |s| should include(s) }
      end
    end
    context 'when there is no samples with given tags' do
      let(:tags) { ['no', 'hell no'] }
      it 'should return empty relation' do
        should be_empty
      end
    end
    context 'when there is samples with some tags given' do
      let(:tags) { ['no', 'tag1', 'tag5', 'hell no'] }
      it 'should return samples with matching tags' do
        should include(samples.first)
        should include(samples.last)
      end
    end
  end
end
