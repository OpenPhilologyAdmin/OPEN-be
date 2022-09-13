# frozen_string_literal: true

require 'rails_helper'

describe CommentSerializer do
  let(:serializer) { described_class.new(record:) }

  describe '#as_json' do
    let(:record) { create(:comment, body: 'This is so nice!') }
    let(:expected_hash) do
      {
        id:           record.id,
        body:         record.body,
        token_id:     record.token_id,
        created_at:   record.created_at,
        created_by:   record.created_by,
        last_edit_at: record.last_edit_at
      }.as_json
    end

    it 'returns serialized hash' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
