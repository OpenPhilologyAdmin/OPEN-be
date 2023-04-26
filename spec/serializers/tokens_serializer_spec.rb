# frozen_string_literal: true

require 'rails_helper'

describe TokensSerializer do
  describe 'as_json' do
    context 'when there are no records' do
      let(:serializer) { described_class.new(records: []) }
      let(:expected_hash) do
        {
          records: [],
          count:   0
        }
      end

      it 'returns hash with correct keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end

    context 'when there are some records' do
      let(:resource) { create(:token, :variant_selected) }
      let(:resource2) { create(:token, apparatus_index: nil) }
      let(:resource3) { create(:token, :variant_selected_and_secondary) }
      let(:expected_record_attributes) { described_class::RecordSerializer::RECORD_ATTRIBUTES }

      context 'when edit mode disabled' do
        let(:serializer) { described_class.new(records: [resource, resource2, resource3]) }
        let(:expected_record_methods) { described_class::RecordSerializer::RECORD_METHODS }
        let!(:expected_hash) do
          {
            records: [
              resource.as_json(
                only:    expected_record_attributes,
                methods: expected_record_methods
              ),
              resource2.as_json(
                only:    expected_record_attributes,
                methods: expected_record_methods
              ),
              resource3.as_json(
                only:    expected_record_attributes,
                methods: expected_record_methods
              ).merge('apparatus_index' => 2)
            ],
            count:   3
          }
        end

        it 'returns hash with correct keys, where only tokens with significant variants have apparatus_index' do
          expect(serializer.as_json).to eq(expected_hash)
        end
      end

      context 'when edit_mode enabled' do
        let(:serializer) { described_class.new(records: [resource, resource2, resource3], edit_mode: true) }
        let(:expected_record_methods) { described_class::RecordSerializer::EDIT_MODE_RECORD_METHODS }
        let!(:expected_hash) do
          {
            records: [
              resource.as_json(
                only:    expected_record_attributes,
                methods: expected_record_methods
              ).merge('apparatus_index' => 1),
              resource2.as_json(
                only:    expected_record_attributes,
                methods: expected_record_methods
              ),
              resource3.as_json(
                only:    expected_record_attributes,
                methods: expected_record_methods
              ).merge('apparatus_index' => 2)
            ],
            count:   3
          }
        end

        it 'returns hash with correct keys, tokens with significant and insignificant variants have apparatus_index' do
          expect(serializer.as_json).to eq(expected_hash)
        end
      end
    end
  end
end
