# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apparatus::SignificantEntry, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:apparatus_significant_entry)).to be_valid
    end

    it 'creates valid :variant_selected factory' do
      expect(build(:apparatus_significant_entry, :variant_selected)).to be_valid
    end

    it 'creates valid :variant_selected_and_secondary factory' do
      expect(build(:apparatus_significant_entry, :variant_selected_and_secondary)).to be_valid
    end
  end

  describe '#value' do
    context 'when there is no variant selected' do
      let(:record) { build(:apparatus_significant_entry) }

      it 'is nil' do
        expect(record.value).to be_nil
      end
    end

    context 'when there is a variant selected' do
      let(:record) { build(:apparatus_significant_entry, :variant_selected) }
      let(:selected_witnesses) { record.selected_variant.witnesses.join(' ') }
      let(:selected_reading) { "#{record.selected_variant.t.strip}]" }
      let(:expected_value) do
        {
          selected_reading:,
          details:
        }
      end

      context 'when there are no secondary variants' do
        let(:details) { selected_witnesses }

        it 'includes the selected reading, its witnesses are in :details' do
          expect(record.value).to eq(expected_value)
        end
      end

      context 'when there are secondary variants' do
        let(:record) { build(:apparatus_significant_entry, :variant_selected_and_secondary) }
        let(:secondary_variants_readings) do
          record.secondary_variants.map do |v|
            "#{v.t.strip} #{v.witnesses.join(' ')}"
          end.join(', ')
        end
        let(:details) { "#{selected_witnesses}, #{secondary_variants_readings}" }

        it 'includes the selected reading, its witnesses and full secondary readings are in :details' do
          expect(record.value).to eq(expected_value)
        end
      end
    end
  end
end
