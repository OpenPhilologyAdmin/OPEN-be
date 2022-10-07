# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Preparers::Models::ValueWithOffsets, type: :model do
  let(:starting_offset) { 2 }
  let(:ending_offset) { value.size - 1 }
  let(:value) { Faker::Lorem.sentence }
  let(:record) { described_class.new(starting_offset:, ending_offset:, value:) }

  describe '#value_before' do
    context 'when given starting_offset is 0' do
      let(:starting_offset) { 0 }

      it 'returns empty string' do
        expect(record.value_before).to be_empty
      end
    end

    context 'when given starting_offset is greater than 0' do
      let(:starting_offset) { 3 }

      it 'returns the text from beginning til offset' do
        expect(record.value_before).to eq(value[0..2])
      end
    end
  end

  describe '#value_after' do
    context 'when given offset is the same as value length' do
      let(:ending_offset) { value.size }

      it 'returns empty string' do
        expect(record.value_after).to be_empty
      end
    end

    context 'when given offset is the lower than value length' do
      let(:ending_offset) { value.size - 1 }

      it 'returns the text from end to the given ending_offset' do
        expect(record.value_after).to eq(value[-1..])
      end
    end
  end
end
