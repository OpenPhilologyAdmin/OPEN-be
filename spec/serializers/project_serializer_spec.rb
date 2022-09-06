# frozen_string_literal: true

require 'rails_helper'

describe ProjectSerializer do
  let(:record) do
    create(:project,
           :with_creator,
           created_at: Time.zone.yesterday.beginning_of_day,
           updated_at: Time.zone.now.beginning_of_day)
  end
  let(:serializer) { described_class.new(record:) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        id:              record.id,
        name:            record.name,
        default_witness: record.default_witness,
        witnesses:       record.witnesses,
        status:          record.status,
        created_by:      record.created_by,
        creator_id:      record.creator_id,
        creation_date:   record.created_at,
        last_edit_by:    record.last_edit_by,
        last_edit_date:  record.updated_at,
        witnesses_count: record.witnesses_count,
        import_errors:   record.import_errors
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
