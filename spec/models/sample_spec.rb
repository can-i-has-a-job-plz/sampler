# frozen_string_literal: true

RSpec.describe Sampler::Sample, type: :model do
  %i(endpoint url request_method).each do |attr|
    context "##{attr}" do
      let(:attribute) { attr }
      it { should respond_to(attr) }
      it { should validate_presence_of(attr) }
    end
  end
  %i(params request_body response_body tags).each do |attr|
    context "##{attr}" do
      let(:attribute) { attr }
      it { should respond_to(attr) }
      it { should_not validate_presence_of(attr) }
      it { should_not allow_value(nil).for(attr).with_message('cannot be nil') }
    end
  end

  context 'creating from Event' do
    let(:event) { create(:event) }
    subject(:sample) { described_class.create(event.to_h) }
    before { %w(tag1 tag2).each { |t| event.tags << t } }

    Sampler::Event.members.each do |member|
      context "##{member}" do
        it "should be equal to Event##{member}" do
          expect(sample.public_send(member)).to eql(event[member])
        end
      end
    end
  end

  context '.with_tags' do
    subject { described_class.with_tags(tags) }
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
        should match_array([samples.first, samples.last])
      end
    end
  end
end
