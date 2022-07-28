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

    context 'when there there is a variant selected' do
      let(:record) { build(:apparatus_significant_entry, :variant_selected) }
      let(:selected_variant) { record.selected_variant }
      let(:expected_reading) { "#{selected_variant.t.strip}] #{selected_variant.witnesses.join(' ')}" }

      it 'includes just the selected reading' do
        expect(record.value).to eq(expected_reading)
      end
    end

    context 'when there there is a selected variant and secondary variants' do
      let(:record) { build(:apparatus_significant_entry, :variant_selected_and_secondary) }
      let(:selected_variant_reading) do
        variant = record.selected_variant
        "#{variant.t.strip}] #{variant.witnesses.join(' ')}"
      end
      let(:secondary_variants_readings) do
        record.secondary_variants.map do |v|
          "#{v.t.strip} #{v.witnesses.join(' ')}"
        end.join(', ')
      end
      let(:expected_reading) do
        "#{selected_variant_reading}, #{secondary_variants_readings}"
      end

      it 'includes the selected reading and secondary readings' do
        expect(record.value).to eq(expected_reading)
      end
    end
  end
end
