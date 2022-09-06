# frozen_string_literal: true

require 'rails_helper'

describe RecordsSerializer do
  let(:record) { create(:user) }
  let(:record2) { create(:user) }
  let(:serializer) { described_class.new(records: [record, record2]) }
  let(:record_serializer) { UserSerializer }

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
      let(:expected_hash) do
        {
          records: [record_serializer.new(record:).as_json, record_serializer.new(record: record2).as_json],
          count:   2
        }
      end

      it 'returns hash with correct keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end
  end
end
