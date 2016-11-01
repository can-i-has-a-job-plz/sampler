# frozen_string_literal: true
RSpec.describe Sample do
  ATTRIBUTES = %i(endpoint url method params request_body response_body
                  tags).freeze

  ATTRIBUTES.each do |attr|
    context "##{attr}" do
      let(:attribute) { attr }
      it { should respond_to(attr) }
      it { should validate_presence_of(attr) }
    end
  end
  it 'should have default value [] for tags' do
    expect(subject.tags).to eq([])
  end
end
