# frozen_string_literal: true

RSpec.shared_examples 'formattable t' do
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
