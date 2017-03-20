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
end
