# frozen_string_literal: true

RSpec.shared_examples 'formattable t' do
  describe '#formatted_t' do
    context 'when :t is not blank' do
      it 'equals the value of :t' do
        resource.t = Faker::Lorem.word
        expect(resource.formatted_t).to eq(resource.t)
      end
    end

    context 'when :t contains only whitespaces' do
      it 'equals the value of :t' do
        resource.t = ' '
        expect(resource.formatted_t).to eq(resource.t)
      end
    end

    context 'when :t is nil' do
      it 'equals the NIL_PLACEHOLDER' do
        resource.t = nil
        expect(resource.formatted_t).to eq(FormattableT::NIL_VALUE_PLACEHOLDER)
      end
    end
  end

  describe '#formatted_value' do
    context 'when :t is present' do
      it 'equals the value of :t without leading and trailing whitespaces' do
        resource.t = " #{Faker::Lorem.word} "
        expect(resource.formatted_value).to eq(resource.t.strip)
      end
    end

    context 'when :t is blank' do
      it 'equals the NULL_PLACEHOLDER' do
        resource.t = nil
        expect(resource.formatted_value).to eq(FormattableT::NIL_VALUE_PLACEHOLDER)
      end
    end
  end
end
