# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/apparatus_serializer'

RSpec.configure do |c|
  c.include Helpers::ApparatusSerializer
end

describe Apparatus::InsignificantEntriesSerializer do
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
      let(:record3) { create(:token, :variant_selected) }
      let(:serializer) { described_class.new(records: [record, record2, record3]) }
      let(:expected_apparatus_entries) do
        serialized_entries(
          [
            build(:apparatus_insignificant_entry, token: record, index: 1),
            build(:apparatus_insignificant_entry, token: record3, index: 3)
          ]
        )
      end

      let(:expected_count) { 2 }

      it 'returns hash with correct keys' do
        expect(serializer.as_json.keys).to match_array(%i[records count])
      end

      it 'does not count the record without insignificant readings' do
        expect(serializer.as_json[:count]).to eq(expected_count)
      end

      it 'includes only the entries with insignificant readings in :records' do
        expect(serializer.as_json[:records]).to eq(expected_apparatus_entries)
      end
    end
  end
end
