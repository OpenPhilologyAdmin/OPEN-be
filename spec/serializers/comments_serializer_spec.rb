# frozen_string_literal: true

require 'rails_helper'

describe CommentsSerializer do
  let(:serializer) { described_class.new(records:) }

  describe '#as_json' do
    let(:expected_record_attributes) { ::CommentSerializer::RECORD_ATTRIBUTES }
    let(:expected_record_methods) { ::CommentSerializer::RECORD_METHODS }

    let(:record1) { create(:comment, body: 'Not funny') }
    let(:record2) { create(:comment, body: 'A bit funny') }
    let(:record3) { create(:comment, body: 'Very funny') }

    let(:serializer) { described_class.new(records: [record1, record2, record3]) }

    let(:expected_hash) do
      [
        record1.as_json(
          only:    expected_record_attributes,
          methods: expected_record_methods
        ),
        record2.as_json(
          only:    expected_record_attributes,
          methods: expected_record_methods
        ),
        record3.as_json(
          only:    expected_record_attributes,
          methods: expected_record_methods
        )
      ]
    end

    it 'returns serialized hash' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
