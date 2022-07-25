# frozen_string_literal: true

require 'rails_helper'

describe Apparatus::EntriesSerializer do
  describe 'as_json' do
    context 'when there are no records' do
      let(:serializer) { described_class.new([]) }
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
      let(:resource2) { create(:token, :variant_selected_and_secondary) }
      let(:serializer) { described_class.new([resource, resource2]) }
      let(:serialized_records) { serializer.as_json[:records] }
      let(:expected_hash) do
        {
          records: [
            Apparatus::EntrySerializer.new(
              Apparatus::Entry.new(token: resource, index: 1)
            ).as_json,
            Apparatus::EntrySerializer.new(
              Apparatus::Entry.new(token: resource2, index: 2)
            ).as_json
          ],
          count:   2
        }
      end

      it 'returns hash with correct keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end
  end
end
