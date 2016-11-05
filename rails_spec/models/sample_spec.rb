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
end
