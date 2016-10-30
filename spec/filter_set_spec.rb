# frozen_string_literal: true
describe Sampler::FilterSet do
  FILTERS = ['whatever', /^whatever$/, -> { 'whatever' }].freeze
  let(:error) { Sampler::FilterClassNotSupported }
  let(:message) { 'Unsupported filter class' }

  context '::new' do
    subject(:action) { -> { Sampler::FilterSet.new(filters) } }
    let(:filter_set) { action.call }

    context 'with no arguments' do
      subject { Sampler::FilterSet.new }
      it { should be_empty }
    end

    context 'with duplicated arguments' do
      subject { Sampler::FilterSet.new(%w(s s)) }
      it 'should have one element' do
        expect(subject.size).to eq(1)
      end
      it 'should have proper element' do
        expect(subject.first).to eq('s')
      end
    end

    context 'with not Enumerable' do
      let(:filters) { Object.new }
      it 'should raise' do
        message = 'value must be enumerable'
        should raise_error(ArgumentError).with_message(message)
      end
    end

    FILTERS.each do |filter|
      context "with one filter, class is #{filter.class}" do
        let(:filters) { [filter] }
        it { should_not raise_error }
        context 'created filter set' do
          it 'should include filter' do
            filters.each { |f| expect(filter_set).to include(f) }
          end
        end
      end
    end

    context 'with multiple filters with allowed classes' do
      let(:filters) { FILTERS }
      it { should_not raise_error }
      context 'created filter set' do
        it 'should include filter' do
          filters.each { |f| expect(filter_set).to include(f) }
        end
      end
    end

    context 'when one filter has unsupported class' do
      let(:filters) { [*FILTERS, Object.new] }
      it { should raise_error(error).with_message(message) }
    end
  end

  context '#add' do
    let(:filter_set) { Sampler::FilterSet.new(['string']) }
    subject(:action) { -> { filter_set.add(filter) } }

    context 'filter is duplicated' do
      let(:filter) { 'string' }
      it { should_not change(filter_set, :size) }
    end

    FILTERS.each do |f|
      context "filter class is #{f.class}" do
        let(:filter) { f }
        it { should_not raise_error }
        it { should change(filter_set, :size).by(1) }
        context 'after addition' do
          before { action.call }
          it 'should include added filter' do
            expect(filter_set).to include(filter)
          end
          it 'should not remove existing filter' do
            expect(filter_set).to include('string')
          end
        end
      end
    end

    context 'filter class is unsupported' do
      let(:filter) { Object.new }
      # rubocop:disable Style/RescueModifier
      let(:action) { -> { filter_set.add(filter) rescue nil } }
      # rubocop:enable Style/RescueModifier
      it { should raise_error(error).with_message(message) }
      it 'should not add a filter' do
        expect(action).not_to change(filter_set, :size)
      end
      context 'after addition' do
        before { action.call }
        it 'should contain existent filters' do
          expect(filter_set).to include('string')
        end
      end
    end
  end
end
