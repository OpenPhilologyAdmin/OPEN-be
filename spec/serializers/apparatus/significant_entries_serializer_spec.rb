# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/apparatus_serializer'

RSpec.configure do |c|
  c.include Helpers::ApparatusSerializer
end

describe Apparatus::SignificantEntriesSerializer do
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
      let(:record) { create(:token, :variant_selected) }
      let(:record2) { create(:token, :variant_selected_and_secondary) }
      let(:serializer) { described_class.new(records: [record, record2]) }
      let(:expected_hash) do
        {
          records: serialized_entries(apparatus_entries),
          count:   2
        }
      end
      let(:apparatus_entries) do
        [
          build(:apparatus_significant_entry, token: record, index: 1),
          build(:apparatus_significant_entry, token: record2, index: 2)
        ]
      end

      it 'returns hash with correct keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end
  end
end
