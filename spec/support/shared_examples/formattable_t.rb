# frozen_string_literal: true

RSpec.shared_examples 'formattable t' do
  context 'when :t is present' do
    it 'equals the value of :t' do
      resource.t = Faker::Lorem.word
      expect(resource.formatted_t).to eq(resource.t)
    end
  end

  context 'when :t is blank' do
    it 'equals the NULL_PLACEHOLDER' do
      resource.t = nil
      expect(resource.formatted_t).to eq(FormattableT::EMPTY_VALUE_PLACEHOLDER)
    end
  end
end
