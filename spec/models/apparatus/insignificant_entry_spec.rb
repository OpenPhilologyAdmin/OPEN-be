# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apparatus::InsignificantEntry do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:apparatus_insignificant_entry)).to be_valid
    end

    it 'creates valid :variant_selected factory' do
      expect(build(:apparatus_insignificant_entry, :variant_selected)).to be_valid
    end
  end

  describe '#value' do
    context 'when there is no variant selected' do
      let(:record) { build(:apparatus_insignificant_entry) }

      it 'is nil' do
        expect(record.value).to be_nil
      end
    end

    context 'when there there is a variant selected' do
      let(:record) { build(:apparatus_insignificant_entry, :variant_selected) }
      let(:selected_reading) { "#{record.selected_variant.formatted_t.strip} ]" }
      let(:selected_witnesses) { record.selected_variant.witnesses.join(' ') }
      let(:insignificant_variants_readings) do
        record.insignificant_variants.map do |v|
          "#{v.witnesses.sort.join(TokenGroupedVariant::WITNESSES_SEPARATOR)}: #{v.formatted_t.strip}"
        end.sort.join(described_class::ENTRIES_SEPARATOR)
      end
      let(:details) { "#{selected_witnesses}#{described_class::ENTRIES_SEPARATOR}#{insignificant_variants_readings}" }

      let(:expected_value) do
        {
          selected_reading:,
          details:
        }
      end

      context 'when :t is present' do
        it 'contains the readings for all of the insignificant variants' do
          expect(record.value).to eq(expected_value)
        end
      end

      context 'when :t is empty' do
        let(:record) { build(:apparatus_insignificant_entry, :variant_selected, with_empty_values: true) }

        it 'contains the readings for all of the insignificant variants' do
          expect(record.value).to eq(expected_value)
        end
      end
    end
  end
end
