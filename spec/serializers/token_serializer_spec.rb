# frozen_string_literal: true

require 'rails_helper'

describe TokenSerializer do
  let(:serializer) { described_class.new(record:) }

  describe '#as_json' do
    context 'when all grouped_variants have values' do
      let(:record) { create(:token, :variant_selected, apparatus_index: 1) }
      let(:expected_hash) do
        {
          id:               record.id,
          apparatus:        record.apparatus,
          grouped_variants: record.grouped_variants,
          variants:         record.variants,
          editorial_remark: record.editorial_remark
        }.as_json
      end

      it 'returns hash with specified keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end

    context 'when the grouped_variants have empty values' do
      let(:record) { create(:token, :variant_selected, apparatus_index: 1, with_empty_values: true) }
      let(:processed_grouped_variants) do
        record.grouped_variants.each do |grouped_variant|
          grouped_variant.t = grouped_variant.formatted_t
        end
      end
      let(:expected_hash) do
        {
          id:               record.id,
          apparatus:        record.apparatus,
          grouped_variants: processed_grouped_variants,
          variants:         record.variants,
          editorial_remark: record.editorial_remark
        }.as_json
      end

      it 'returns hash with specified keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end

      it 'replaces empty values for the grouped variants' do
        serializer.as_json['grouped_variants'].each do |grouped_variant|
          expect(grouped_variant['t']).not_to be_blank
        end
      end
    end
  end
end
